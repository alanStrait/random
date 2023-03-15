# Random

## Elixir / Erlang / OTP versions
At the time of this writing, the latest Erlang/OTP, Elixir, and Phoenix were used. Phoenix 1.7, now has `Verified Routes`, including the new sigil `~p`, and colocated controller and view modules (directory structure is a bit different than in the past).  Hopefully it is convenient by way of `asdf` or equivalent for you to run this project with the following versions.
```zsh
Erlang/OTP 25 [erts-13.2] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Elixir 1.14.3 (compiled with Erlang/OTP 25)
```

## Quickstart
This repository, [git@github.com:alanStrait/random.git](git@github.com:alanStrait/random.git).

```zsh
git clone git@github.com:alanStrait/random.git
cd random
## Be sure Postgres is available with un/pw in `dev.exs`
# `mix setup` is designed for only the first time setup
mix setup
# Please use `mix ecto.reset` for `n + 1` setup
mix ecto.reset
# Run tests
mix test
## start phoenix
mix phx.server 
# or
iex -S mix phx.server
# with this option, you can also start the `observer`
:observer.start()
```
API, visit: [http://localhost:4000](http://localhost:4000/)

Each time this endpoint is invoked it will return two or fewer users with randomly attributed points that happen to be greater than a minimum number kept internally and that is updated every minute.  It will also return the timestamp for the prior invocation.

Dashboard, visit: [http://localhost:4000/dev/dashboard/home](http://localhost:4000/dev/dashboard/home)

## This `Random` Implementation
This repository contains a backend code exercise provided by a prospective employer.  The following highlevel description reflects my understanding of provided `Requirements`.  Thoughts and observations are interspersed in context.

- [x] A good README.md
- [x] Use Postgres
  - [x] See `dev.exs` for `Repo` configuration  
- [x] `mix` commands used to bootstap this project / repository
  - [x] `mix phx.new random --no-assets --no-html --no-gettext --no-mailer`
    - [x] Two URLs are operative given these options
      - [x] `http://localhost:4000/`
        - [x] Endpoint for provided API
      - [x] `http://localhost:4000/dev/dashboard/home`
        - [x] Dashboard when in `dev` mode
  - [x] `mix phx.gen.json Accounts User users points:integer`
    - [x] Only an `index/2` function on the controller was kept in order to provide the single endpoint described
  - [x] All default configuration options provided by `mix` have been kept
  - [x] Unneeded functions and tests were removed along the way
    - [x] An effort was made to implement only the requirements specified, with an exception of baisc CRUD function in the `Accounts` context module
      - [x] `delete_user/1` was removed
- [x] `User` schema with four fields: `id`, `points`, and `timestamps` generated by Ecto, `inserted_at` and `updated_at`
    - [x] On `mix setup` and `mix ecto.reset` this schema is to create `1_000_000` records with points initialized to zero
      - [x] Initially I was concerned that a singleton `GenServer` was going to be a bottleneck when updating these records, but this turned out to be unfounded given `insert_all` (used in `seeds.exs`) and `update_all` used directly in the `GenServer`.
        - [x] `seeds.exs` loads in approximately 10 seconds
        - [x] Update of all points with new random numbers takes between 10 and 15 seconds, well within the 60 second window
        - [x] `update_all`, by way of `insert_all` with the `on_conflict` option, was kept as a private function in the `GenServer` as it would not be expected to be part of the public API in the context module, `Accounts`, since it circumvents schema validation
- [x] No warnings on application start, `mix phx.server` or `iex -S mix phx.server`
- [x] A singleton data container `GenServer` that:
    - [x] Starts at application startup
    - [x] Manages two properties
      - [x] `min_number`, an integer between 0 and 100
      - [x] A timestamp, I chose to call `last_queried`, that is updated on query request, initialized to be `nil`
        - [x] When `last_queried` is nil, I interpret the output to be `"timestamp":"first query"`, which was not specified in the requirements
    - [x] Runs every minute to 
      - [x] Update all `1_000_000` users points with a new random number between 0 and 100
        - [x] Note: this implementation takes advantage of knowing the `User` ids are integers and contiguous from 1 to 1_000_000  
          - [x] For fast update where such assumptions could not be made, I would generally cache the pertinent `User` ids in `ETS` or equivalent
        - [x] `:rand.uniform/1` seems to provide a good distribution of numbers as can be seen using this query by way of `psql` or other SQL client of Postgres:
          - [x] `select points, count(*) from users group by points order by 2 desc;`
      - [x] Update `min_number` with a new random number between 0 and 100 once points are updated
    - [x] A single `handle_call` that 
      - [x] Finds all users with `points` greater than `min_number`
      - [x] Returns the first two of these users along with the `last_queried` timestamp for the prior query, and
      - [x] Updates `last_queried` with a new timestamp
    - [x] Note, I have used a `boundary` directory for the `GenServer`, following a suggestion by James Gray and Bruce Tate in `"Designing Elixir Systems with OTP"`, but I did not place `User` in a `core` directory, but rather treated the `accounts` directory as core
      - [x] This may be overkill for this short exercise
- [x] A single endpoint for an API call to return two users whose points are greater than `min_number`
  - [x] [http://localhost:4000/](http://localhost:4000/)

## Bootstrap (See Quickstart above)

