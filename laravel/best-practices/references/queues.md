# Queues & Jobs

## Creating a job
```bash
php artisan make:job ProcessPodcast
```

```php
class ProcessPodcast implements ShouldQueue
{
    use Dispatchable, InteractsWithQueue, Queueable, SerializesModels;

    public int $tries = 3;           // max attempts before failure
    public int $backoff = 60;        // seconds between retries (or array [60, 120, 300])
    public int $timeout = 120;       // seconds before job is killed
    public int $maxExceptions = 2;   // fail after N uncaught exceptions (not retries)

    public function __construct(
        private Podcast $podcast,    // Eloquent models are auto-serialized by ID and re-fetched
    ) {
        // Only pass what you need — avoid serializing large objects
        $this->onQueue('podcasts')->onConnection('redis');
    }

    public function handle(AudioProcessor $processor): void
    {
        // Dependencies injected from service container
        $processor->process($this->podcast);
    }

    public function failed(Throwable $e): void
    {
        // Called when all retries exhausted — notify, clean up, etc.
    }
}
```

## Dispatching
```php
// Default queue
ProcessPodcast::dispatch($podcast);

// Override queue/connection at dispatch time
ProcessPodcast::dispatch($podcast)->onQueue('high')->onConnection('sqs');

// Delay
ProcessPodcast::dispatch($podcast)->delay(now()->addMinutes(5));

// After DB transaction commits (prevent race conditions)
ProcessPodcast::dispatch($podcast)->afterCommit();

// Conditionally dispatch
ProcessPodcast::dispatchIf($podcast->needsProcessing(), $podcast);
ProcessPodcast::dispatchUnless($podcast->isProcessed(), $podcast);

// Sync (run inline, no queue — useful in tests)
ProcessPodcast::dispatchSync($podcast);
```

## Unique jobs
```php
class UpdateSearchIndex implements ShouldQueue, ShouldBeUnique
{
    public int $uniqueFor = 3600;  // lock expires after 1 hour

    public function uniqueId(): string
    {
        return $this->product->id; // one job per product at a time
    }
}
// Requires a cache driver that supports atomic locks (Redis, DB, file, etc.)
```

## Job middleware
```php
// Rate limiting via middleware (preferred over inline)
public function middleware(): array
{
    return [new RateLimited('backups')];
}
// Define limiter in AppServiceProvider:
RateLimiter::for('backups', fn ($job) => Limit::perHour(1)->by($job->user->id));

// Prevent overlap (only one running at a time per key)
use Illuminate\Queue\Middleware\WithoutOverlapping;
public function middleware(): array
{
    return [new WithoutOverlapping($this->podcast->id)];
}

// Skip when a condition is met
use Illuminate\Queue\Middleware\Skip;
public function middleware(): array
{
    return [Skip::when($this->podcast->isArchived())];
}
```

## Job batching
```php
use Illuminate\Bus\Batch;
use Illuminate\Support\Facades\Bus;

$batch = Bus::batch([
    new ProcessPodcast($podcast1),
    new ProcessPodcast($podcast2),
])->then(fn (Batch $batch) => // all succeeded
    Log::info('All done')
)->catch(fn (Batch $batch, Throwable $e) => // first failure
    Log::error($e->getMessage())
)->finally(fn (Batch $batch) => // always runs
    $batch->delete()
)->onQueue('podcasts')->dispatch();

$batchId = $batch->id; // store for status polling
Bus::findBatch($batchId)->progress(); // 0–100
```

## Chained jobs
```php
ProcessPodcast::withChain([
    new OptimizePodcast($podcast),
    new NotifySubscribers($podcast),
])->dispatch($podcast);
// Each runs only if the previous succeeded
```

## Running workers
```bash
php artisan queue:work                  # default connection & queue
php artisan queue:work redis --queue=high,default  # priority queues
php artisan queue:work --tries=3 --timeout=120
php artisan queue:work --stop-when-empty    # exit when queue is empty (good for Lambda)

# Supervisor config: restart worker after each job to avoid stale state
php artisan queue:work --max-jobs=100

# After deploying new code, restart workers gracefully
php artisan queue:restart
```

## Failed jobs
```bash
php artisan queue:failed          # list
php artisan queue:retry all       # re-queue all
php artisan queue:retry <id>      # re-queue specific
php artisan queue:forget <id>     # delete specific
php artisan queue:flush            # delete all
```

```php
// Retry after specific time
public function retryUntil(): DateTime
{
    return now()->addHours(2);
}
```

## Horizon (Redis only — recommended)
```bash
composer require laravel/horizon
php artisan horizon:install
php artisan horizon             # run all workers per config
php artisan horizon:pause / resume / terminate
```
Configure in `config/horizon.php` — define environments, queue workers, and balancing strategies.

## Config quick reference
```php
// config/queue.php defaults
'default' => env('QUEUE_CONNECTION', 'database'),

// .env
QUEUE_CONNECTION=redis
```
