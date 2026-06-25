# Validation & Form Requests

## Always use Form Requests
```bash
php artisan make:request StorePostRequest
# Placed in app/Http/Requests/
```

```php
class StorePostRequest extends FormRequest
{
    public function authorize(): bool
    {
        // Return false to auto-403; use Gate/Policy here if needed
        return $this->user()->can('create', Post::class);
    }

    public function rules(): array
    {
        return [
            'title'        => ['required', 'string', 'max:255'],
            'body'         => ['required', 'string'],
            'published_at' => ['nullable', 'date'],
            'status'       => ['required', Rule::in(['draft', 'published'])],
            'tags'         => ['array', 'max:10'],
            'tags.*'       => ['integer', 'exists:tags,id'],
            'category_id'  => ['required', Rule::exists('categories', 'id')->whereNull('deleted_at')],
            'email'        => [
                'required', 'email:rfc,dns',
                Rule::unique('users', 'email')->ignore($this->user()->id), // on update
            ],
        ];
    }

    public function messages(): array
    {
        return [
            'title.required' => 'A title is required.',
        ];
    }

    public function attributes(): array
    {
        return ['category_id' => 'category']; // nicer field names in error messages
    }

    // Additional validation after rules pass
    public function after(): array
    {
        return [
            function (Validator $validator) {
                if ($this->somethingElseFails()) {
                    $validator->errors()->add('field', 'Custom error message.');
                }
            },
        ];
    }

    // Optionally transform / filter validated data before use
    protected function prepareForValidation(): void
    {
        $this->merge(['slug' => Str::slug($this->title)]);
    }
}
```

## Controller usage
```php
public function store(StorePostRequest $request): RedirectResponse
{
    // $request->validated() — ONLY validated fields (safe to pass to create/update)
    $post = Post::create($request->validated());

    // Subset of validated fields
    $post = Post::create($request->safe()->only(['title', 'body']));
    $post->fill($request->safe()->except(['title']));
}
```

## Common rule patterns
```php
// Unique with exceptions (update flows)
Rule::unique('users')->ignore($user->id)
Rule::unique('users')->where('tenant_id', $this->tenant_id)

// Exists with constraints
Rule::exists('categories', 'id')->where('active', true)

// Enum validation (PHP backed enums)
Rule::enum(StatusEnum::class)

// Conditional rules
Rule::requiredIf($this->input('type') === 'company')
Rule::excludeIf($this->input('type') === 'guest')

// Stop on first failure for a field
'title' => ['bail', 'required', 'string', 'max:255']

// Nullable optional fields (needed because TrimStrings converts '' to null)
'bio' => ['nullable', 'string', 'max:1000']

// Password with confirm
'password' => ['required', 'confirmed', Password::min(8)->letters()->numbers()->uncompromised()]

// File upload
'avatar' => ['file', 'image', 'mimes:jpg,jpeg,png,webp', 'max:2048', 'dimensions:min_width=100']
```

## Array / nested validation
```php
'addresses'         => ['required', 'array', 'min:1'],
'addresses.*.line1' => ['required', 'string'],
'addresses.*.city'  => ['required', 'string'],
'meta.company'      => ['nullable', 'string'], // dot syntax for nested
```

## Inline validation (use sparingly — controller logic only)
```php
$validated = $request->validate([
    'email' => ['required', 'email'],
]);
// Redirect with errors on failure (XHR → 422 JSON)
```

## Manual validator
```php
$validator = Validator::make($data, $rules);

if ($validator->fails()) {
    return back()->withErrors($validator)->withInput();
}

$validated = $validator->validated();
```

## Displaying errors in Blade
```blade
@error('title')
    <p class="error">{{ $message }}</p>
@enderror

{{-- Named error bag (e.g. from validateWithBag) --}}
@error('title', 'createPost')
    <p class="error">{{ $message }}</p>
@enderror

{{-- Repopulate input --}}
<input type="text" name="title" value="{{ old('title') }}">
```

## XHR / API responses
- On failure, Laravel returns `422 Unprocessable Content` with JSON:
  ```json
  { "message": "The title field is required.", "errors": { "title": ["The title field is required."] } }
  ```
- Inertia.js: errors auto-flow via `$page.props.errors` — no manual handling needed.

## Gotchas
- `nullable` is required on optional fields because the `ConvertEmptyStringsToNull` middleware converts `''` to `null`, which would otherwise fail `string` rules.
- `exists:` does not exclude soft-deleted rows — use `Rule::exists()->whereNull('deleted_at')`.
- `unique:` ignoring a record by id: always use `Rule::unique()->ignore($id)`, not the string shorthand.
