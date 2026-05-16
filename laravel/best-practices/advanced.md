# Laravel — Advanced Patterns

Sections 13–15 from [SKILL.md](SKILL.md). Load when the user asks about rate limiting, event-driven architecture, or model lifecycle hooks. Only suggest these for Medium/Complex projects.

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
