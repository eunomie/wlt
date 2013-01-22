# Web Log Today

A ~~world domniation plan~~ static web/site generator, written in ruby.

## Installation

As `wlt` is based on [sub][], installation is very easy!

You need git and ruby (only tested with 1.9.3) and [bundler][].

1. Get the sources

    ```sh
    git clone git://github.com/CrEv/wlt.git
    ```
2. Run [bundler][] to install gems

    ```sh
    bundle
    ```
3. Install it.

    For bash :
    ```sh
    echo 'eval "$(<wltpath>/bin/wlt init -)"' >> ~/.bash_profile
    exec bash
    ```

    For zsh :
    ```sh
    echo 'eval "$(<wltpath>/bin/wlt init -)"' >> ~/.zshenv
    source ~/.zshenv
    ```

## Update

```sh
git pull && bundle
```

## Branches

After the first release, the `master` branch will be a stable branch that can be deployed at every moment.

All work will be done in feature branches, without a `dev/devel/develop` branch.

## Usage

The easiest way to start is to use one of the two scaffolding included, basic or full.

```sh
wlt scaffold basic
```

or

```sh
wlt scaffold full
```

After that, just run the local server, browse http://localhost:4000 and enjoy!

```sh
wlt serve
```

## Contributing

Don't hesitate to fill issues or submit pull requests `;-)`

[sub]: https://github.com/37signals/sub
[bundler]: http://gembundler.com/
