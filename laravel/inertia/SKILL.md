---
name: laravel-inertia-snippets
description: >
  General-purpose best practices for Laravel + Inertia.js with React. Use this skill for ANY
  Laravel/Inertia question: project setup, page/data flow, forms, layouts, navigation, partial
  reloads, shared data, deferred props, optimistic updates, SSR, or general architecture decisions.
  Trigger on keywords like: Inertia, useForm, usePage, InertiaLink, partial reload, HandleInertiaRequests,
  Inertia::render, @inertiajs/react, or any question about connecting Laravel controllers to React pages.
  The user knows Laravel basics (Eloquent, FormRequests, ORM) — skip those fundamentals.
---

# Laravel + Inertia.js — General Best Practices (React)

**Stable stack:** Laravel 11+, Inertia.js v2, React 18, Vite  
**v3 (beta):** Inertia v3 + React 19 — new features flagged as `[v3]` below  
Focus: Inertia-specific patterns only.

---

## 1. Project Structure

```
resources/js/
├── Pages/              # One component per route — maps to Inertia::render() paths
│   ├── Auth/
│   └── Users/
│       ├── Index.jsx
│       ├── Show.jsx
│       ├── Create.jsx
│       └── Edit.jsx
├── Components/         # Pure UI, no page-level logic
├── Layouts/
│   └── AppLayout.jsx
└── app.jsx
```

---

## 2. Setup (`app.jsx`)

```jsx
// v2
import { createInertiaApp } from '@inertiajs/react'
import { resolvePageComponent } from 'laravel-vite-plugin/inertia-helpers'

createInertiaApp({
  resolve: name => resolvePageComponent(
    `./Pages/${name}.jsx`,
    import.meta.glob('./Pages/**/*.jsx')
  ),
  setup({ el, App, props }) {
    createRoot(el).render(<App {...props} />)
  },
})
```

```jsx
// [v3] — @inertiajs/vite plugin handles resolution automatically
// createInertiaApp() with no arguments works out of the box
```

---

## 3. Controller → Page (Server Side)

```php
// Always use API Resources — never pass raw Eloquent models
return Inertia::render('Users/Index', [
    'users' => UserResource::collection(User::paginate(20)),
    'filters' => $request->only('search', 'role'),
]);
```

**Lazy / deferred props** — load heavy data only on partial reload:
```php
// v2
return Inertia::render('Reports/Show', [
    'report' => $report,
    'stats'  => Inertia::lazy(fn () => $this->computeStats()),  // deprecated in v3
]);

// [v3] — renamed
'stats' => Inertia::optional(fn () => $this->computeStats()),
```

**Once props** `[v3]` — send a prop only on the initial full page load, never on partial reloads:
```php
'config' => Inertia::once($globalConfig),
```

---

## 4. Shared Data (Middleware)

```php
// App\Http\Middleware\HandleInertiaRequests.php
public function share(Request $request): array
{
    return [
        ...parent::share($request),
        'auth'  => ['user' => $request->user()?->only('id', 'name', 'email')],
        'flash' => ['success' => fn () => $request->session()->get('success')],
    ];
}
```

Access anywhere in React:
```jsx
import { usePage } from '@inertiajs/react'
const { auth, flash } = usePage().props
```

**Layout props** `[v3]` — pass data directly into a persistent layout without polluting page props:
```jsx
import { useLayoutProps } from '@inertiajs/react'
const { notifications } = useLayoutProps()
```

---

## 5. Forms with `useForm()`

```jsx
import { useForm } from '@inertiajs/react'

const { data, setData, post, put, processing, errors, reset } = useForm({
  name: '',
  email: '',
})

function submit(e) {
  e.preventDefault()
  post(route('users.store'), { onSuccess: () => reset() })
}

// Edit form — initialize from props
const form = useForm({ name: user.name, email: user.email })
form.put(route('users.update', user.id))
```

Validation errors from `FormRequest` populate `errors` automatically — no extra wiring.

**File uploads:**
```jsx
const { data, setData, post, progress } = useForm({ avatar: null })
setData('avatar', e.target.files[0])
// progress.percentage available during upload
```

**Standalone HTTP requests** `[v3]` — non-page-visit requests with same DX as useForm:
```jsx
import { useHttp } from '@inertiajs/react'
const { post, processing } = useHttp()
post(route('likes.store', post.id))  // no page navigation, just a request
```

---

## 6. Partial Reloads

```jsx
import { router } from '@inertiajs/react'

// Refresh only specific props (async in v2+)
router.get(route('users.index'), { search: query }, {
  preserveState: true,
  replace: true,
  only: ['users'],
})
```

Use `preserveState: true` to keep scroll position and local state during filter/sort.  
Use `preserveErrors: true` `[v3]` to keep validation errors visible during a partial reload.

**Deferred props + `<Deferred>`** — render a loading state while heavy props load:
```jsx
import { Deferred } from '@inertiajs/react'

<Deferred data="stats" fallback={<Spinner />}>
  {({ stats }) => <StatsChart data={stats} />}
</Deferred>
```

---

## 7. Layouts (Persistent)

```jsx
// Pages/Users/Index.jsx
import AppLayout from '@/Layouts/AppLayout'

export default function Index({ users }) {
  return <div>...</div>
}

// Persistent layout — component persists across visits, only children re-render
Index.layout = page => <AppLayout>{page}</AppLayout>
```

**Default layout** `[v3]` — set a default in `createInertiaApp` to avoid repeating on every page:
```jsx
createInertiaApp({
  layout: page => <AppLayout>{page}</AppLayout>,
  // per-page .layout still overrides this
})
```

---

## 8. Links & Navigation

```jsx
import { Link, router } from '@inertiajs/react'

// Declarative — uses XHR, not full page load
<Link href={route('users.show', user.id)} preserveScroll>View</Link>

// Programmatic
router.visit(route('users.index'))
router.get('/users', { search: 'john' }, { preserveState: true })
router.delete(route('users.destroy', id), { preserveScroll: true })
```

**Instant visits** `[v3]` — swap to the target component immediately, before the server responds:
```jsx
<Link href={route('users.index')} instant>Users</Link>
```

**Prefetching** `[v3]`:
```jsx
<Link href={route('users.show', id)} prefetch>View</Link>
```

---

## 9. Optimistic Updates `[v3]`

See [v3.md](v3.md) for optimistic updates and all other v3-only features (instant visits, prefetching, `useHttp`, `once` props, layout props, `preserveErrors`).

---

## 10. Title & Meta

```jsx
import { Head } from '@inertiajs/react'

<Head>
  <title>Users</title>
  <meta name="description" content="Manage users" />
</Head>
```

Set a global title template in `createInertiaApp`:
```jsx
createInertiaApp({ title: title => `${title} — MyApp` })
```

In `app.blade.php`, use `<title data-inertia>` `[v3]` (was `inertia` attribute in v2).

---

## 11. Pagination

```jsx
// Laravel paginator serializes to { data, links, meta }
{users.links.map(link => (
  <Link
    key={link.label}
    href={link.url}
    preserveScroll
    dangerouslySetInnerHTML={{ __html: link.label }}
  />
))}
```

---

## 12. Flash Messages

```php
// Controller
return redirect()->route('users.index')->with('success', 'User created.');
```
```jsx
// Layout / any component
const { flash } = usePage().props
{flash.success && <Alert>{flash.success}</Alert>}
```

---

## 13. Error Handling

```jsx
// Per-visit exception handling [v3]
router.post(route('users.store'), data, {
  onHttpException: (response) => {
    // handle 4xx/5xx without navigating away
  },
})
```

For global 404/500 pages, create `Pages/Error.jsx` and configure in `HandleExceptions`.

---

## 14. What NOT to Do

| Avoid | Use instead |
|---|---|
| Raw Eloquent models as props | API Resources |
| `<a href>` for internal links | `<Link>` |
| Axios for form submissions | `useForm()` |
| Axios for non-page requests | `useHttp()` `[v3]` |
| Layout wrapped in component body | `.layout` property |
| Client-side data fetching on mount | Pass via `Inertia::render()` |
| `Inertia::lazy()` (v3) | `Inertia::optional()` |
| Server state in Zustand/Context | Inertia props; local state for pure UI |

---

## Version Summary

See [v3.md](v3.md) for the complete v2 → v3 migration reference and all v3-specific features.
