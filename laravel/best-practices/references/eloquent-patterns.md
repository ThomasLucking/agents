# Eloquent Patterns

## Model conventions
```php
// Table: auto snake_case plural of class name (Flight → flights)
// Override: protected $table = 'my_flights';
// Primary key: 'id' (int, incrementing) — override: protected $primaryKey = 'uuid';

// UUIDs: use HasUuids trait — generates UUIDv7 (lexicographically sortable)
use Illuminate\Database\Eloquent\Concerns\HasUuids;

// Disable timestamps: public $timestamps = false;
// Custom timestamp columns: const CREATED_AT = 'created'; const UPDATED_AT = 'modified';
// Modify timestamps without touching updated_at:
$model->withoutTimestamps(fn () => $model->update(['status' => 'archived']));
```

## Retrieving records
```php
User::all();                          // Collection — never null
User::find(1);                        // null if not found
User::findOrFail(1);                  // throws ModelNotFoundException
User::firstOrCreate(['email' => $e], ['name' => $n]); // find or insert
User::firstOrNew([...]);              // find or new (not saved)
User::updateOrCreate(['email' => $e], ['name' => $n]);
User::upsert([...], uniqueBy: ['email'], update: ['name']); // bulk upsert

// Check for empty collection
$users = User::where('active', true)->get();
if ($users->isEmpty()) { ... }  // NOT null check
```

## Query scopes
```php
// Local scope — call as ->active()
public function scopeActive(Builder $query): void
{
    $query->where('active', true);
}

// Scope with parameters
public function scopeOfType(Builder $query, string $type): void
{
    $query->where('type', $type);
}

// Global scope — applies automatically to all queries for the model
protected static function booted(): void
{
    static::addGlobalScope('active', fn (Builder $q) => $q->where('active', true));
}
// Bypass global scope: User::withoutGlobalScope('active')->get();
```

## Mass assignment
```php
// Option 1: explicit allow-list
protected $fillable = ['name', 'email'];

// Option 2: explicit block-list (guard nothing by default — risky)
protected $guarded = ['id', 'password'];

// fill() / create() / update() all respect $fillable
$user = User::create($request->validated()); // always use validated() input
```

## Soft deletes
```php
use SoftDeletes; // adds deleted_at column

$user->delete();           // sets deleted_at — row stays in DB
User::find(1);             // soft-deleted rows silently excluded
User::withTrashed()->find(1);  // include soft-deleted
User::onlyTrashed()->get();    // only soft-deleted
$user->restore();
$user->forceDelete();      // permanent
```

## Chunking / cursors (large datasets)
```php
// chunk: loads N records at a time — safe for mutation
User::chunk(200, function (Collection $users) { ... });

// cursor: PHP generator — one model at a time, single query
foreach (User::cursor() as $user) { ... }

// lazy: Collection-style chaining over chunks
User::lazy(500)->filter(...)->each(...);
```

## Replicating
```php
$replica = $post->replicate()->fill(['title' => 'Copy of ' . $post->title]);
$replica->save();
```

## Model events / observers
```php
// In AppServiceProvider or model boot:
User::creating(fn ($user) => $user->uuid = Str::uuid());

// Observer class (preferred for multiple events)
php artisan make:observer UserObserver --model=User
// Register: User::observe(UserObserver::class);

// Mute events during bulk ops (e.g. seeding)
User::withoutEvents(fn () => User::factory()->count(100)->create());
```

## Strictness (enable in development)
```php
// AppServiceProvider::boot()
Model::preventLazyLoading(! app()->isProduction());
Model::preventSilentlyDiscardingAttributes(! app()->isProduction());
```

## Accessors / Mutators / Casts
```php
// Accessor + Mutator (Laravel 9+ syntax)
protected function firstName(): Attribute
{
    return Attribute::make(
        get: fn ($value) => ucfirst($value),
        set: fn ($value) => strtolower($value),
    );
}

// Casts (preferred over mutators for type coercion)
protected function casts(): array
{
    return [
        'is_admin'     => 'boolean',
        'metadata'     => 'array',       // JSON column ↔ PHP array
        'published_at' => 'datetime',
        'status'       => StatusEnum::class, // PHP backed enum
        'price'        => 'decimal:2',
    ];
}
// Array cast gotcha: mutate via reassignment, not direct offset
$model->options = array_merge($model->options, ['key' => 'val']);
```

## Append computed attributes
```php
protected $appends = ['full_name']; // included in toArray()/toJson()

protected function fullName(): Attribute
{
    return Attribute::make(get: fn () => "{$this->first_name} {$this->last_name}");
}
```
