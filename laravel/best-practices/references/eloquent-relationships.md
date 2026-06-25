# Eloquent Relationships

## Defining relationships
```php
// hasOne / hasMany — FK lives on the OTHER table
public function phone(): HasOne   { return $this->hasOne(Phone::class); }
public function posts(): HasMany  { return $this->hasMany(Post::class); }

// belongsTo — FK lives on THIS model's table
public function user(): BelongsTo { return $this->belongsTo(User::class); }

// Many-to-many — pivot table (alphabetical: posts_tags, role_user)
public function roles(): BelongsToMany { return $this->belongsToMany(Role::class); }

// Through
public function deployments(): HasManyThrough
{
    return $this->hasManyThrough(Deployment::class, Environment::class);
}
```

## Eager loading (prevent N+1)
```php
// Always eager-load when iterating relationships
$posts = Post::with('comments')->get();
$posts = Post::with(['comments', 'author', 'tags'])->get();

// Nested eager loading
$posts = Post::with('comments.author')->get();

// Constrained eager loading
$posts = Post::with(['comments' => fn ($q) => $q->where('approved', true)])->get();

// Lazy eager load (after retrieval)
$posts->load('comments');

// Prevent N+1 at the model level in dev:
Model::preventLazyLoading(! app()->isProduction());
```

## Many-to-many pivot
```php
// Access pivot data
$user->roles->first()->pivot->created_at;

// Custom pivot columns: withPivot()
$this->belongsToMany(Role::class)->withPivot('expires_at')->withTimestamps();

// Syncing (removes then re-attaches)
$user->roles()->sync([1, 2, 3]);
$user->roles()->syncWithoutDetaching([4]); // attach only

// Attaching / detaching
$user->roles()->attach($roleId, ['expires_at' => now()->addYear()]);
$user->roles()->detach($roleId);

// Update pivot row
$user->roles()->updateExistingPivot($roleId, ['expires_at' => now()]);
```

## Has-one-of-many (latest/oldest)
```php
// Get user's most recent order
public function latestOrder(): HasOne
{
    return $this->hasOne(Order::class)->latestOfMany();
}

// Custom: most expensive order
public function mostExpensiveOrder(): HasOne
{
    return $this->hasOne(Order::class)->ofMany('amount', 'max');
}
```

## Polymorphic relationships
```php
// In Image model:
public function imageable(): MorphTo { return $this->morphTo(); }

// In Post / User:
public function images(): MorphMany { return $this->morphMany(Image::class, 'imageable'); }

// Register morph map to avoid class-name coupling
Relation::enforceMorphMap([
    'post' => Post::class,
    'user' => User::class,
]);
```

## Scoped relationships
```php
// Relationship with built-in constraint
public function publishedPosts(): HasMany
{
    return $this->hasMany(Post::class)->withAttributes(['published' => true]);
    // withAttributes() adds WHERE clause AND sets attribute on create()
}
```

## Default models (Null Object pattern)
```php
// Returns an empty User model instead of null
public function author(): BelongsTo
{
    return $this->belongsTo(User::class)->withDefault(['name' => 'Anonymous']);
}
```

## Querying relationships
```php
// "Does post have any comments?"
Post::has('comments')->get();
Post::has('comments', '>=', 3)->get();

// Constrained existence
Post::whereHas('comments', fn ($q) => $q->where('approved', true))->get();

// Does not have
Post::doesntHave('comments')->get();

// withCount — adds comments_count attribute
Post::withCount('comments')->get();

// whereBelongsTo — cleaner than where('user_id', $user->id)
Post::whereBelongsTo($user)->get();
```

## Chaperone — prevent N+1 on parent from child
```php
// Auto-hydrates $comment->post without extra queries when looping children
public function comments(): HasMany
{
    return $this->hasMany(Comment::class)->chaperone();
}
```
