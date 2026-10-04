---
name: laravel-best-practices
description: >
  General-purpose Laravel best practices focused on using what Laravel already provides instead of
  reinventing it. Use this skill for ANY Laravel question about how to implement something — validation,
  auth, file storage, background jobs, caching, HTTP calls, routing, Eloquent patterns, or general
  architecture. Trigger on questions like "how do I implement X", "should I use a package for Y",
  "how do I build Z", or when reviewing Laravel code. Always point to the exact docs section, explain
  why it's relevant to their specific project, and calibrate suggestions to project complexity —
  never suggest an advanced feature unless the basics are solid and the project actually needs it.
  The user knows Laravel basics (Eloquent, controllers, routing) — skip those fundamentals.
---

# Laravel Best Practices — Use What's Already There

**Stack:** Laravel 12 (same for 11 unless noted)  
**Philosophy:** Get the basics right first. Suggest advanced features only when the project complexity justifies it.

---

## How to Use This Skill

When the user describes what they're building:
1. **Verify the basics are correct first** — is validation in a FormRequest? Are queries scoped? Is auth using the built-in system?
2. **Point out what Laravel already provides** if they're reinventing it — with the exact docs URL
3. **Only suggest advanced patterns** (events, observers, batching) if the project is complex enough to warrant them
4. **Be specific about why** it applies to *their* project — not generic

> Always include the exact URL. Never say "check the docs". Base: `https://laravel.com/docs/12.x/`

---

## Complexity Tiers

Use these to decide what to suggest:

- **Simple** — CRUD app, personal project, small team, <10 models
- **Medium** — Growing product, multiple devs, background tasks, external APIs
- **Complex** — Multi-tenant, high traffic, many async processes, real-time features

Don't suggest Complex-tier solutions to a Simple project. Don't leave a Complex project using Simple patterns.

---

## 1. Validation & Form Requests

**The baseline (always enforce):** validation never belongs inline in a controller.

```php
// ❌ Don't
public function store(Request $request) {
    $request->validate(['title' => 'required', 'body' => 'required|string']);
}

// ✅ Do — moves validation + authorization out of the controller
php artisan make:request StorePostRequest
```

```php
class StorePostRequest extends FormRequest {
    public function rules(): array {
        return [
            'title' => ['required', 'string', 'max:255'],
            'body'  => ['required', 'string'],
            'tags'  => ['nullable', 'array'],
            'tags.*'=> ['string', 'max:50'],
        ];
    }

    public function authorize(): bool {
        return $this->user()->can('create', Post::class);
    }
}
```

📖 `laravel.com/docs/12.x/validation#form-request-validation`

**Suggest when:** Any action with 3+ fields, or where authorization logic exists alongside validation.

> **Advanced (suggest for Medium+):** `prepareForValidation()` to normalize data before rules run, `after()` hooks for cross-field validation, and `messages()` for custom error text. Only bring these up if the user has complex validation logic already.

---

## 2. Authorization — Gates & Policies

**The baseline:** don't scatter `if ($user->role === 'admin')` in controllers.

```php
// ❌ Don't
if ($user->id !== $post->user_id) abort(403);

// ✅ Do — define ownership/permission once, use everywhere
php artisan make:policy PostPolicy --model=Post
```

```php
class PostPolicy {
    public function update(User $user, Post $post): bool {
        return $user->id === $post->user_id;
    }
}
```

```php
// In controller
$this->authorize('update', $post);

// In Blade
@can('update', $post) <button>Edit</button> @endcan
```

📖 `laravel.com/docs/12.x/authorization`

**Suggest when:** Any resource that has an owner, or when the same permission check appears in 2+ places.

> **Advanced (suggest for Medium+):** Gates for non-model checks (`Gate::define('view-dashboard', ...)`), Policy `before()` method for admins who bypass all checks. Don't suggest a full role/permission package (like Spatie) unless the project has many distinct roles with complex permission matrices.

---

## 3. Eloquent — Scopes, Relationships, Accessors

**The baseline:** don't repeat query conditions and don't access raw attributes when a cleaner alternative exists.

### Scopes — stop copying `->where()` chains
```php
// ❌ Don't — repeated in 4 controllers
User::where('active', true)->where('verified', true)->get();

// ✅ Do
public function scopeActive(Builder $query): void {
    $query->where('active', true)->where('verified', true);
}

User::active()->latest()->paginate(20);
```

📖 `laravel.com/docs/12.x/eloquent#query-scopes`

### Accessors & Casts — don't compute in views
```php
// ❌ Don't — formatting in Blade/component
{{ $user->first_name . ' ' . $user->last_name }}

// ✅ Do — define once on the model
protected function fullName(): Attribute {
    return Attribute::make(get: fn () => "{$this->first_name} {$this->last_name}");
}

// And use casts for types
protected $casts = [
    'settings'   => 'array',
    'is_active'  => 'boolean',
    'published_at'=> 'datetime',
];
```

📖 `laravel.com/docs/12.x/eloquent-mutators`

**Suggest when:** Same `->where()` chain in 2+ places; date/money/boolean formatting happening in views.

> **Advanced (suggest for Medium+):** Global scopes when a condition applies to *every* query on a model (e.g. multi-tenancy filtering). Only suggest if it's clearly needed — global scopes are invisible and can confuse if overused.

---

## 4. Controllers — Keep Them Thin

**The baseline:** controllers should validate → delegate → respond. Business logic does not belong there.

```php
// ❌ Don't — business logic + side effects in controller
public function store(StoreOrderRequest $request) {
    $order = Order::create($request->validated());
    $order->items()->createMany($request->items);
    Mail::to($request->user())->send(new OrderConfirmation($order));
    $request->user()->loyalty_points += 10;
    $request->user()->save();
    return redirect()->route('orders.show', $order);
}

// ✅ Do — controller just coordinates
public function store(StoreOrderRequest $request) {
    $order = $this->orderService->create($request->user(), $request->validated());
    return redirect()->route('orders.show', $order);
}
```

Move business logic into a **Service class** or **Action class** — plain PHP classes in `app/Services/` or `app/Actions/`.

📖 `laravel.com/docs/12.x/controllers`

**Suggest when:** A controller method is longer than ~20 lines or mixes 3+ concerns.

> **Advanced (suggest for Medium+):** Single Action Controllers (`__invoke`) for actions that only ever do one thing. Keeps the file focused.
> ```php
> php artisan make:controller PublishPostController --invokable
> Route::post('/posts/{post}/publish', PublishPostController::class);
> ```
> 📖 `laravel.com/docs/12.x/controllers#single-action-controllers`

---

## 5. Routing

**The baseline:** group related routes, use named routes, never hardcode URLs.

```php
// ❌ Don't
Route::get('/admin/users', [UserController::class, 'index']);
Route::get('/admin/users/{user}', [UserController::class, 'show']);

// ✅ Do — grouped, named via resource
Route::prefix('admin')->middleware('auth')->group(function () {
    Route::resource('users', UserController::class);
});

// Use named routes everywhere — never hardcode /admin/users
route('users.index')
redirect()->route('users.show', $user)
```

📖 `laravel.com/docs/12.x/routing`

**Suggest when:** Hardcoded URLs in views/redirects; routes that share middleware not grouped together.

> **Advanced (suggest for Medium+):** Route model binding with custom resolution logic when the default `{user}` binding isn't enough (e.g. find by slug instead of ID).
> ```php
> public function resolveRouteBinding($value, $field = null) {
>     return $this->where('slug', $value)->firstOrFail();
> }
> ```
> 📖 `laravel.com/docs/12.x/routing#customizing-the-resolution-logic`

---

## 6. Authentication

**The baseline:** use Laravel's built-in `Auth` — don't manually check passwords or manage sessions.

```php
// ❌ Don't — manual password comparison
if ($user->password === hash('sha256', $request->password)) { ... }

// ✅ Do
if (Auth::attempt($request->only('email', 'password'))) {
    $request->session()->regenerate();
    return redirect()->intended('/dashboard');
}
```

For **API / SPA token auth** — Sanctum handles this without building a token system:
```php
// Issue token
$token = $user->createToken('api-token')->plainTextToken;

// Protect routes
Route::middleware('auth:sanctum')->get('/user', fn (Request $r) => $r->user());
```

📖 Auth: `laravel.com/docs/12.x/authentication`  
📖 Sanctum: `laravel.com/docs/12.x/sanctum`

**Suggest Sanctum when:** Any project with an API, mobile app, or a decoupled SPA frontend. If they're using `tymon/jwt-auth` on a new project — Sanctum covers the same need natively.

---

## 7. File Storage

**The baseline:** never use `move_uploaded_file()` directly — use the Storage facade.

```php
// ❌ Don't
move_uploaded_file($tmp, public_path('uploads/' . $filename));

// ✅ Do — driver-agnostic, testable, works local → S3 with .env change
$path = $request->file('avatar')->store('avatars', 'public');

// Or with a custom name
$path = Storage::disk('public')->putFileAs('avatars', $request->file('avatar'), $user->id.'.jpg');

// Generate a public URL
$url = Storage::url($path);
```

📖 `laravel.com/docs/12.x/filesystem`

**Suggest when:** Any file upload. The disk abstraction means switching from local to S3 is a `.env` change.

> **Advanced (suggest for Medium+):** Temporary signed URLs for private files (e.g. user documents that shouldn't be publicly accessible):
> ```php
> $url = Storage::temporaryUrl('documents/contract.pdf', now()->addMinutes(30));
> ```

---

## 8. HTTP Client

**The baseline:** don't use `curl_*` functions or install Guzzle manually — it's already wrapped.

```php
// ❌ Don't
$ch = curl_init('https://api.example.com/users');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
$response = curl_exec($ch);

// ✅ Do
$response = Http::withToken($apiKey)
    ->post('https://api.example.com/users', ['name' => 'Thomas']);

$data = $response->json();
$response->throw(); // throws on 4xx/5xx
```

📖 `laravel.com/docs/12.x/http-client`

**Suggest when:** Any external API call. `Http::fake()` in tests makes mocking trivial — that alone is worth switching.

> **Advanced (suggest for Medium+):** `->retry(3, 200)` for flaky external APIs; `Http::pool()` for concurrent requests. Only suggest if they're already using the client and have reliability or performance needs.

---

## 9. Caching

**The baseline:** use the Cache facade — don't build a manual "cache table" or repeat expensive queries.

```php
// ❌ Don't — query on every request
$settings = Setting::all()->keyBy('key');

// ✅ Do — cache it, auto-refreshes when missing
$settings = Cache::remember('app.settings', now()->addHour(), fn () =>
    Setting::all()->keyBy('key')
);

// Simple get/put
Cache::put('user.'.$id.'.profile', $data, now()->addDay());
$data = Cache::get('user.'.$id.'.profile');

// Forget on update
Cache::forget('app.settings');
```

📖 `laravel.com/docs/12.x/cache`

**Suggest when:** Any query result that doesn't change on every request, or any external API response worth caching.

> **Advanced (suggest for Complex):** Cache tags for invalidating groups of related keys. Only suggest if they have multiple related cache entries that need to be busted together — overkill for simple key-based caching.

---

## 10. Background Jobs & Queues

**The baseline:** anything that can fail, is slow, or shouldn't block a response → move to a job.

```php
php artisan make:job SendWelcomeEmail
```

```php
class SendWelcomeEmail implements ShouldQueue {
    public function __construct(public User $user) {}

    public function handle(): void {
        Mail::to($this->user)->send(new WelcomeMail($this->user));
    }
}

// Dispatch from anywhere
SendWelcomeEmail::dispatch($user);
SendWelcomeEmail::dispatch($user)->delay(now()->addMinutes(5));
```

📖 `laravel.com/docs/12.x/queues`

**Suggest when:** Sending email, calling external APIs, processing uploads, generating reports, anything that takes >300ms.

> **Advanced (suggest for Medium+):** Job chaining for sequential steps; `$this->release()` to retry a job with a delay; `$tries` and `$backoff` for resilient jobs that hit flaky APIs. Only introduce when they have actual multi-step async workflows or retry needs.

---

## 11. Mail

**The baseline:** don't use `mail()` or `PHPMailer` directly — use Laravel's Mailable.

```php
php artisan make:mail OrderConfirmation --markdown=emails.orders.confirmation
```

```php
class OrderConfirmation extends Mailable {
    public function __construct(public Order $order) {}

    public function envelope(): Envelope {
        return new Envelope(subject: 'Your order is confirmed');
    }

    public function content(): Content {
        return new Content(markdown: 'emails.orders.confirmation');
    }
}

// Send
Mail::to($user->email)->send(new OrderConfirmation($order));

// Queue it (almost always should)
Mail::to($user->email)->queue(new OrderConfirmation($order));
```

📖 `laravel.com/docs/12.x/mail`

**Suggest when:** Any email sending. `->queue()` instead of `->send()` is an easy win if queues are set up.

---

## 12. Scheduling

**The baseline:** don't maintain multiple cron jobs — one entry drives everything.

```php
// routes/console.php (Laravel 11+)
Schedule::command('app:send-reminders')->dailyAt('08:00');
Schedule::job(new CleanupExpiredTokens)->hourly();
Schedule::call(fn () => /* ... */)->weekly();
```

One server cron entry:
```
* * * * * cd /var/www && php artisan schedule:run >> /dev/null 2>&1
```

📖 `laravel.com/docs/12.x/scheduling`

**Suggest when:** Any recurring task. If they have multiple cron entries doing `php artisan X` — consolidate them.

> **Advanced (suggest for Medium+):** `->withoutOverlapping()` to prevent a slow job from running concurrently; `->onOneServer()` for multi-server deployments. Only suggest if they've hit these problems.

---

## 13. Rate Limiting

**The baseline:** don't build a manual counter with `Cache::increment()`.

```php
// In AppServiceProvider::boot()
RateLimiter::for('api', function (Request $request) {
    return Limit::perMinute(60)->by($request->user()?->id ?: $request->ip());
});

// On routes — one line
Route::middleware('throttle:api')->group(fn () => /* ... */);

// Or shorthand
Route::middleware('throttle:60,1')->group(fn () => /* ... */);
```

📖 `laravel.com/docs/12.x/routing#rate-limiting`

**Suggest when:** Any public endpoint, login form, or form submission that could be abused.

---

## 14. Events & Listeners

**The baseline:** don't cram side effects into service methods or controllers.

```php
php artisan make:event UserRegistered
php artisan make:listener SendWelcomeEmail --event=UserRegistered
```

```php
// Listener can be queued automatically
class SendWelcomeEmail implements ShouldQueue {
    public function handle(UserRegistered $event): void {
        Mail::to($event->user)->queue(new WelcomeMail($event->user));
    }
}

// Fire anywhere
event(new UserRegistered($user));
```

📖 `laravel.com/docs/12.x/events`

**Suggest when:** A single action (user registered, order placed) triggers 2+ side effects. Events let each effect live in isolation.

> **Advanced (suggest for Medium+):** Model events (`User::created(fn () => ...)`) for lightweight hooks; Observers when multiple events on the same model need handling. Introduce Observers only when model lifecycle callbacks are scattered — not as a default pattern.

---

## 15. Model Observers

> **This is an advanced suggestion — only bring up when justified.**

An Observer consolidates all Eloquent lifecycle hooks for a model in one place.

```php
php artisan make:observer OrderObserver --model=Order
```

```php
class OrderObserver {
    public function created(Order $order): void { /* notify team */ }
    public function updated(Order $order): void { /* invalidate cache */ }
    public function deleted(Order $order): void { /* cleanup related records */ }
}
```

📖 `laravel.com/docs/12.x/eloquent#observers`

**Suggest when:** The same model has lifecycle logic duplicated across `store()`, `update()`, and `destroy()` in controllers. If a model only needs one hook, a simple model event is lighter — don't reach for an Observer for that.

---

## Suggestion Rules

**Always do:**
- Verify basics are correct before suggesting anything advanced
- Cite the exact docs URL (`laravel.com/docs/12.x/[page]`)
- Explain why it fits *this* project, not generically
- Flag when they're reinventing something that already exists

**Never do:**
- Suggest Observers, Events, Batching, Scout, Pennant, Reverb, or Horizon to a Simple project
- Recommend third-party packages without first checking if Laravel covers it natively
- List all features — identify the 1-3 actually relevant to what they're building
- Suggest adding infrastructure (Redis, external search, WebSockets) before confirming the simpler built-in option won't work

**Quick reinvention check:**

| If you see this... | Laravel already has... | Docs |
|---|---|---|
| `curl_*` / raw Guzzle | `Http::` client | `12.x/http-client` |
| `move_uploaded_file()` | `Storage::` facade | `12.x/filesystem` |
| Manual password hashing | `Auth::attempt()` | `12.x/authentication` |
| Inline `$request->validate()` | `FormRequest` | `12.x/validation` |
| `if ($user->role === 'admin')` | Gates + Policies | `12.x/authorization` |
| `mail()` or raw PHPMailer | `Mailable` + `Mail::` | `12.x/mail` |
| `Cache::get/set` with manual keys | `Cache::remember()` | `12.x/cache` |
| `exec()` for background work | `ShouldQueue` jobs | `12.x/queues` |
| Multiple cron entries | `Schedule::` | `12.x/scheduling` |
| Manual `Cache::increment` for throttle | `RateLimiter::for()` | `12.x/routing#rate-limiting` |
| Same `->where()` chain in 3+ places | Model scopes | `12.x/eloquent#query-scopes` |
| JWT via third-party package | Sanctum | `12.x/sanctum` |
