# Notifications

## Creating a notification
```bash
php artisan make:notification InvoicePaid
```

```php
class InvoicePaid extends Notification implements ShouldQueue
{
    use Queueable;

    public function __construct(public Invoice $invoice) {}

    // Determine delivery channels per notifiable
    public function via(object $notifiable): array
    {
        return $notifiable->prefers_sms ? ['vonage'] : ['mail', 'database'];
    }

    public function toMail(object $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject('Invoice Paid')
            ->greeting("Hello {$notifiable->name}!")
            ->line("Invoice #{$this->invoice->number} has been paid.")
            ->action('View Invoice', route('invoices.show', $this->invoice))
            ->line('Thank you for your business.');
    }

    public function toDatabase(object $notifiable): array
    {
        return [
            'invoice_id' => $this->invoice->id,
            'amount'     => $this->invoice->amount,
        ];
    }

    public function toArray(object $notifiable): array
    {
        return $this->toDatabase($notifiable); // toArray() used by the 'database' channel
    }
}
```

## Sending notifications
```php
// Via the Notifiable trait on the model (e.g. User)
$user->notify(new InvoicePaid($invoice));

// Via facade (multiple notifiables)
Notification::send(User::all(), new InvoicePaid($invoice));

// Immediately (bypass ShouldQueue)
Notification::sendNow($user, new InvoicePaid($invoice));
```

## The Notifiable trait
```php
// User model (and any other model you notify)
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;

    // Override routing per channel:
    public function routeNotificationForMail(): string
    {
        return $this->email;
    }

    public function routeNotificationForVonage(): string
    {
        return $this->phone_number;
    }
}
```

## Database notifications
```bash
php artisan make:notifications-table
php artisan migrate
```

```php
// Access a user's notifications
$user->notifications;               // all (Collection of DatabaseNotification models)
$user->unreadNotifications;
$user->readNotifications;

// Mark as read
$user->unreadNotifications->markAsRead();
$notification->markAsRead();

// Delete
$user->notifications()->delete();
```

## Queueing & delays
```php
class InvoicePaid extends Notification implements ShouldQueue
{
    public int $tries = 3;
    public int $backoff = 60;

    // Delay per channel
    public function withDelay(object $notifiable): array
    {
        return ['mail' => now()->addMinutes(5)];
    }

    // Specify queue per channel
    public function viaQueues(): array
    {
        return ['mail' => 'mail', 'database' => 'default'];
    }

    // Only send if still relevant when the job runs
    public function shouldSend(object $notifiable, string $channel): bool
    {
        return ! $this->invoice->isCancelled();
    }
}

// Dispatch after DB transaction commits
$user->notify((new InvoicePaid($invoice))->afterCommit());
```

## Markdown notifications
```php
public function toMail(object $notifiable): MailMessage
{
    return (new MailMessage)->markdown('mail.invoice.paid', [
        'invoice' => $this->invoice,
    ]);
}
// resources/views/mail/invoice/paid.blade.php — uses @component('mail::...')
```

## On-demand notifications (no model required)
```php
Notification::route('mail', 'support@example.com')
    ->route('vonage', '+15551234567')
    ->notify(new InvoicePaid($invoice));
```

## Custom channels
Implement `Illuminate\Notifications\Channels\Channel`:
```php
public function send(mixed $notifiable, Notification $notification): void
{
    $data = $notification->toPushNotification($notifiable);
    // push to external service
}
```
Register in `AppServiceProvider` or a dedicated `NotificationServiceProvider`.

## Testing
```php
Notification::fake();

$user->notify(new InvoicePaid($invoice));

Notification::assertSentTo($user, InvoicePaid::class, fn ($n) =>
    $n->invoice->is($invoice)
);
Notification::assertNotSentTo($user, SomeOtherNotification::class);
Notification::assertCount(1);
Notification::assertNothingSent();
```
