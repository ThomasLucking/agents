# Laravel — Infrastructure & Data Patterns

Sections 7–12 from [SKILL.md](SKILL.md). Load when the user asks about file storage, HTTP calls, caching, background jobs, email, or task scheduling.

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
