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

## Infrastructure & Data Patterns

See [async.md](async.md) for: **File Storage** · **HTTP Client** · **Caching** · **Background Jobs** · **Mail** · **Scheduling**

## Advanced Patterns

See [advanced.md](advanced.md) for: **Rate Limiting** · **Events & Listeners** · **Model Observers**

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
