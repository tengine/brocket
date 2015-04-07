# brocket

brocket supports to build docker image with VERSION file and git.
You can define setup and teardown around `docker build` by writing
config IMAGE_NAME and hooks like BEFORE_BUILD and AFTER_BUILD.

## Behavior

- `brocket release`
    1. check the local repository si clean and commited
    2. same as `brocket docker build`
    3. push by git
    4. push by docker
- `brocket docker build`
    1. call BEFORE_BUILD
    2. `docker build` with arguments
        - call ON_BUILD_COMPLETE on success
        - call ON_BUILD_ERROR on failure
    3. call AFTER_BUILD

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'brocket'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install brocket

## Usage

### init

```
brocket init
```

Then VERSION file will be created.

### add config

add following line to your Dockerfile.

```
# [config] IMAGE_NAME: "groovenauts/rails-example"
```

example https://github.com/tengine/brocket/blob/master/spec/brocket/Dockerfiles/Dockerfile-basic#L2

### bump up VERSION

When you increment VERSION file, you can use theese commands.

```
brocket version major   # bump up major version of VERSION file
brocket version minor   # bump up minor version of VERSION file
brocket version bump    # bump up last number of VERSION file
```

### Hooks

You can define commands to execute around `docker build` like this:

```
# [config] IMAGE_NAME: "groovenauts/rails-example"
# [config]
# [config] BEFORE_BUILD:
# [config]   - abc
# [config]   - def ghi
# [config]
# [config] AFTER_BUILD:
# [config]   - "jkl"
# [config]   - mno
# [config]
# [config] ON_BUILD_COMPLETE: foo bar
# [config]
# [config] ON_BUILD_ERROR: "baz"
# [config]
```


https://github.com/tengine/brocket/blob/master/spec/brocket/Dockerfiles/Dockerfile-hook


### For more information

```
brocket help
```

or https://github.com/tengine/brocket/tree/master/spec/brocket



## Contributing

1. Fork it ( https://github.com/groovenauts/brocket/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
