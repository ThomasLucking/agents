# Security Checklist

## Authentication
```php
// Use starter kits (Breeze / Jetstream) — don't hand-roll auth
// Sanctum for SPAs and simple API tokens; Passport only if full OAuth2 needed

// Get authenticated user
$user = Auth::user();
$user = $request->user();

// Check auth state
Auth::check();   // true if logged in
Auth::guest();   // true if not logged in

// Protect routes
Route::middleware('auth')->group(fn () => ...);
Route::middleware(['auth', 'verified'])->group(fn () => ...); // + email verified

// Logout — invalidate session AND regenerate token
Auth::logout();
$request->session()->invalidate();
$request->session()->regenerateToken();
```

## Authorization — Gates & Policies
```php
// Gate: quick capability check
Gate::define('update-post', fn (User $user, Post $post) => $user->id === $post->user_id);
Gate::authorize('update-post', $post);   // throws 403 if denied
$this->authorize('update', $post);       // in controllers via AuthorizesRequests

// Policy: model-bound authorization (preferred)
php artisan make:policy PostPolicy --model=Post

// Policy methods must return bool or Response
public function update(User $user, Post $post): bool
{
    return $user->id === $post->user_id;
}

// Register in AppServiceProvider:
Gate::policy(Post::class, PostPolicy::class);

// Use in controller:
$this->authorize('update', $post);

// Use in Blade:
@can('update', $post) ... @endcan
@cannot('delete', $post) ... @endcannot
```

## CSRF
- All non-GET routes in the `web` middleware group are CSRF-protected automatically.
- Blade forms: always include `@csrf`.
- API routes (stateless) do not need CSRF — exclude from `VerifyCsrfToken` or use `api` middleware group.
- SPA with Sanctum: call `/sanctum/csrf-cookie` before first request.

## Input validation — always via Form Requests
```php
php artisan make:request StorePostRequest

// In StorePostRequest:
public function authorize(): bool { return true; } // do authz check here or via Gate

public function rules(): array
{
    return [
        'title'   => ['required', 'string', 'max:255'],
        'body'    => ['required', 'string'],
        'email'   => ['required', 'email:rfc,dns'],
        'price'   => ['required', 'numeric', 'min:0'],
        'user_id' => ['required', 'exists:users,id'],
        'tags'    => ['array', 'max:5'],
        'tags.*'  => ['string', 'distinct'],
        'file'    => ['file', 'mimes:pdf,png', 'max:2048'],
    ];
}

// Controller:
public function store(StorePostRequest $request): RedirectResponse
{
    Post::create($request->validated()); // only validated fields, never $request->all()
}
```

## Mass assignment protection
```php
// Never: Post::create($request->all())
// Always:
Post::create($request->validated());
Post::create($request->safe()->only(['title', 'body']));
```

## SQL injection
```php
// Safe — parameterised bindings
DB::select('select * from users where id = ?', [$id]);
DB::table('users')->where('id', $id)->get();

// Unsafe — never interpolate user input
DB::select("select * from users where id = $id"); // NEVER
```

## XSS
```blade
{{ $variable }}      {{-- escaped — safe --}}
{!! $variable !!}    {{-- raw — only use for trusted, sanitized HTML --}}
```

## File uploads
```php
$path = $request->file('avatar')->store('avatars', 'private'); // store outside public/
// Validate MIME and extension, not just extension:
'file' => ['file', 'mimes:jpg,png', 'max:4096'],
// Regenerate filename (storeAs uses the user-supplied name — avoid)
$filename = Str::uuid() . '.' . $request->file('avatar')->extension();
```

## Sensitive data
```php
// Passwords: always hash with bcrypt (Hash facade, never MD5/SHA)
Hash::make($password);

// Encrypt arbitrary values:
Crypt::encryptString($value);
Crypt::decryptString($encrypted);

// Use cast on model for transparent encryption:
protected function casts(): array { return ['ssn' => 'encrypted']; }

// Never log passwords, tokens, or PII
// Hide sensitive attributes from serialization:
protected $hidden = ['password', 'remember_token'];
```

## Rate limiting
```php
// Route-level throttle middleware
Route::middleware('throttle:60,1')->group(fn () => ...);   // 60/min

// Named rate limiter (AppServiceProvider)
RateLimiter::for('api', function (Request $request) {
    return $request->user()
        ? Limit::perMinute(60)->by($request->user()->id)
        : Limit::perMinute(10)->by($request->ip());
});
Route::middleware(['auth:sanctum', 'throttle:api'])->group(...);
```

## Headers / HTTPS
- Set `APP_ENV=production` and `APP_DEBUG=false` in production.
- Force HTTPS: `URL::forceScheme('https')` in `AppServiceProvider` or use a load balancer.
- Sanctum SPA cookie: `SESSION_SECURE_COOKIE=true`, `SESSION_DOMAIN=.example.com`.

## Common gotchas
- `exists:users,id` validation rule does not check soft-deleted rows — add `Rule::exists('users')->whereNull('deleted_at')` if needed.
- `unique` validation bypasses the current record on update: `Rule::unique('users')->ignore($user->id)`.
- Always use `$request->validated()` not `$request->all()` when creating/updating models.
