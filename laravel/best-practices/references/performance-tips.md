# Performance Tips

## N+1 query prevention

```php
// BAD — 1 query for posts + 1 per post for author
$posts = Post::all();
foreach ($posts as $post) {
    echo $post->author->name; // N queries
}

// GOOD — 2 queries total
$posts = Post::with('author')->get();

// Nested relationships
$posts = Post::with('author.profile', 'tags', 'comments')->get();

// Constrained eager load
$posts = Post::with(['comments' => fn ($q) => $q->where('approved', true)->latest()])->get();

// withCount — adds {relation}_count attribute (1 extra query)
$posts = Post::withCount('comments')->get();
// $post->comments_count

// Detect N+1 in dev:
Model::preventLazyLoading(! app()->isProduction());
```

## Select only what you need
```php
User::select('id', 'name', 'email')->get();      // don't select *
Post::with('author:id,name')->get();             // constrain eager-loaded columns
```

## Chunking large datasets
```php
// chunk: fires a new query every N rows — safe to mutate within
Post::chunk(500, function ($posts) {
    $posts->each->archive();
});

// lazy: Collection API over cursor — single query, memory-efficient
Post::lazy(500)->filter(...)->each->archive();

// cursor: lowest memory, one model at a time
foreach (Post::cursor() as $post) { ... }

// NEVER call ->all() or ->get() on millions of rows
```

## Database indexes
```php
// Migration — index on frequently queried/sorted columns
$table->index('created_at');
$table->index(['user_id', 'status']);   // composite: order matches query
$table->unique(['email', 'tenant_id']);

// Full-text search index (MySQL/PostgreSQL)
$table->fullText('body');
```

## Caching
```php
use Illuminate\Support\Facades\Cache;

// Remember — fetch from cache, or compute and store
$users = Cache::remember('active-users', now()->addMinutes(10), fn () =>
    User::where('active', true)->get()
);

// Forever
Cache::rememberForever('config-settings', fn () => Setting::all()->keyBy('key'));

// Manual store / retrieve / forget
Cache::put('key', $value, $ttl);
Cache::get('key', $default);
Cache::forget('key');
Cache::flush();

// Tags (Redis / Memcached only — not file/DB driver)
Cache::tags(['posts', 'users'])->put('key', $value, 60);
Cache::tags('posts')->flush();

// Atomic lock (prevent stampede / duplicate processing)
$lock = Cache::lock('process-report', 120);
if ($lock->get()) {
    try { ... } finally { $lock->release(); }
}
```

## Query builder tips
```php
// Avoid N+1 with subquery selects
$users = User::addSelect([
    'latest_post_title' => Post::select('title')
        ->whereColumn('user_id', 'users.id')
        ->latest()
        ->limit(1),
])->get();

// pluck() when you only need one column
$emails = User::where('active', true)->pluck('email'); // Collection of strings

// value() for a single scalar
$name = User::where('id', 1)->value('name');

// exists() / doesntExist() — cheaper than count()
if (Post::where('user_id', $userId)->exists()) { ... }

// Bulk insert (no model events, no timestamps unless you add them)
DB::table('logs')->insert([...]);
// With model events, use chunk-based upsert or saveMany:
$post->comments()->saveMany($comments);
```

## Pagination
```php
// Always paginate — never ->get() on user-facing lists
$posts = Post::latest()->paginate(20);
$posts = Post::latest()->simplePaginate(20);  // prev/next only, cheaper COUNT query
$posts = Post::latest()->cursorPaginate(20);  // cursor-based, fastest for large tables
```

## Queue heavy operations
- Send emails via `Mail::queue()` / `ShouldQueue` — never block a request.
- Image resizing, PDF generation, report exports → jobs.
- Third-party API calls in jobs whenever possible.

## Config / route caching (production)
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan event:cache
# Clear all: php artisan optimize:clear
```

## DB connection pooling
- Use PgBouncer (PostgreSQL) or ProxySQL (MySQL) in production.
- Set `DB_PERSISTENT=false` — Laravel reconnects per request by default; persistent connections leak under workers.

## Redis for sessions & cache
```env
SESSION_DRIVER=redis
CACHE_STORE=redis
QUEUE_CONNECTION=redis
```
Avoid the `database` driver for sessions/cache under load — it creates per-request DB writes.
