# RabbitCI BuildMan test repos

These test repos are used for the build manager so we do not have to
make requests to GitHub every time we run our tests. However, because
we also need access to `pull/#/head` and `pull/#/merge` refs we cannot
simply add a submodule. Instead, our solution is this:

- Create git bundle of repo we want (from a --mirror clone so we get
  all the pr refs).
- Add it to this directory.

Here's an example:

    ❯ git clone --mirror git@github.com:rabbit-ci/example-project.git
    Cloning into bare repository 'example-project.git'...
    remote: Counting objects: 28, done.
    remote: Total 28 (delta 0), reused 0 (delta 0), pack-reused 27
    Receiving objects: 100% (28/28), done.
    Resolving deltas: 100% (11/11), done.
    Checking connectivity... done.

    ❯ git -C example-project.git/ bundle create example-project.bundle --all
    Counting objects: 28, done.
    Delta compression using up to 8 threads.
    Compressing objects: 100% (14/14), done.
    Writing objects: 100% (28/28), 3.37 KiB | 0 bytes/s, done.
    Total 28 (delta 11), reused 28 (delta 11)

    ❯ git bundle verify example-project.git/example-project.bundle
    The bundle contains these 4 refs:
    eccee02ec18a36bcb2615b8c86d401b0618738c2 refs/heads/master
    bfbfad7e9ba8e8f36d500218e11d40200701d74b refs/pull/1/head
    b78104685141fec938866fd4591bfc0caaee9424 refs/pull/1/merge
    eccee02ec18a36bcb2615b8c86d401b0618738c2 HEAD
    The bundle records a complete history.
    example-project.git/example-project.bundle is okay
