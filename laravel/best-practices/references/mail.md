# Mail

## Mailable structure
```bash
php artisan make:mail OrderShipped        # creates app/Mail/OrderShipped.php
php artisan make:mail OrderShipped --markdown=emails.orders.shipped
```

```php
class OrderShipped extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public Order $order) {} // public props auto-injected into view

    public function envelope(): Envelope
    {
        return new Envelope(
            subject: 'Order Shipped',
            // from: new Address('ship@example.com', 'Shipping'), // override global from
            replyTo: [new Address('support@example.com')],
        );
    }

    public function content(): Content
    {
        return new Content(
            view: 'emails.orders.shipped',   // Blade view
            // markdown: 'emails.orders.shipped',  // or Markdown
            // text: 'emails.orders.shipped-plain', // optional plain-text version
            with: ['trackingUrl' => $this->order->trackingUrl()], // extra view data
        );
    }

    public function attachments(): array
    {
        return [
            Attachment::fromPath(storage_path('invoices/invoice.pdf'))
                ->as('Invoice.pdf')
                ->withMime('application/pdf'),
            // Attachment::fromStorage('invoices/invoice.pdf'),   // from disk
            // Attachment::fromData(fn() => $pdf->output(), 'invoice.pdf'),  // raw bytes
        ];
    }
}
```

## Sending
```php
use Illuminate\Support\Facades\Mail;

// Immediately
Mail::to($user)->send(new OrderShipped($order));

// Queue it (recommended for user-facing flows)
Mail::to($user)->queue(new OrderShipped($order));

// CC / BCC
Mail::to($user)->cc($manager)->bcc('archive@example.com')->send(...);

// Multiple recipients
Mail::to([$user1, $user2])->send(...);

// Later
Mail::to($user)->later(now()->addMinutes(10), new OrderShipped($order));
```

## Queued mailables
```php
class OrderShipped extends Mailable implements ShouldQueue
{
    use Queueable, SerializesModels;

    public int $tries = 3;
    public int $backoff = 60;     // seconds between retries

    // Dispatch on specific queue
    public function __construct(public Order $order)
    {
        $this->onQueue('mail')->onConnection('redis');
    }
}
// Dispatch as normal — Laravel detects ShouldQueue automatically
Mail::to($user)->send(new OrderShipped($order));
```

## Global from address (config/mail.php)
```php
'from' => ['address' => 'hello@example.com', 'name' => 'App Name'],
```

## Markdown mailables
```php
// content() → markdown: 'emails.orders.shipped'
// resources/views/emails/orders/shipped.blade.php:
@component('mail::message')
# Order Shipped

Your order **{{ $order->number }}** is on its way.

@component('mail::button', ['url' => $trackingUrl])
Track Order
@endcomponent

Thanks,
{{ config('app.name') }}
@endcomponent
```

## Inline images
```blade
<img src="{{ $message->embed(public_path('logo.png')) }}">
```

## Testing mailables
```php
Mail::fake();

$response = $this->post('/orders', [...]);

Mail::assertSent(OrderShipped::class, fn ($mail) =>
    $mail->hasTo($user->email) && $mail->order->is($order)
);
Mail::assertNotSent(OrderShipped::class);
Mail::assertQueued(OrderShipped::class);
Mail::assertNothingOutgoing();
```

## Drivers reference
| Driver      | Install                                                  |
|-------------|----------------------------------------------------------|
| SMTP        | built-in                                                 |
| Mailgun     | `composer require symfony/mailgun-mailer`                |
| Postmark    | `composer require symfony/postmark-mailer`               |
| Resend      | `composer require resend/resend-php`                     |
| SES         | `composer require aws/aws-sdk-php`                       |
| Failover    | built-in (wraps multiple mailers, no extra package)      |
| Round-robin | built-in (distributes load across mailers)               |
