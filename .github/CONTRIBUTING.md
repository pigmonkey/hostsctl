# Hostctl: contributing

Follow these guidelines if you'd like to contribute to hostsctl.

---

### Table of Contents

Read through these guidelines before you get started:

1. [Questions & Concerns](#questions--concerns)
2. [Issues & Bugs](#issues--bugs)
3. [Feature Requests](#feature-requests)
4. [Submitting Pull Requests](#submitting-pull-requests)
5. [Code Style](#code-style)

### Questions & Concerns

If you have any questions about using or developing hostsctl, reach out
to @0xl3vi or send an [email][1].

### Issues & Bugs

Submit an [issue][2] or [pull request][3] with a fix if you find any bugs in
hostsctl. See [below](#submitting-pull-requests) for instructions on sending
in pull requests, and be sure to reference the [code style guide](#code-style)
first!

When submitting an issue or pull request, make sure you're as detailed as possible
and fill in all answers to questions asked in the templates. For example, an issue
that simply states "X/Y/Z isn't working!" will be closed.

### Feature Requests

Submit an [issue][2] to request a new feature. Features fall into one of two
categories:

1. **Major**: Major changes should be discussed with me via [email][1]. I'm
always open to suggestions and will get back to you as soon as I can!
2. **Minor**: A minor feature can simply be added via a [pull request][3].

### Submitting Pull Requests

Before you do anything, make sure you check the current list of [pull requests][4]
to ensure you aren't duplicating anyone's work. Then, do the following:

1. Fork the repository and make your changes in a git branch: `git checkout -b my-branch base-branch`
2. Read and follow the [code style guidelines](#code-style).
3. Make sure your feature or fix doesn't break the project! Test thoroughly.
4. Commit your changes, and be sure to leave a detailed commit message.
5. Push your branch to your forked repo on GitHub: `git push origin my-branch`
6. [Submit a pull request][3] and hold tight!
7. If any changes are requested by the project maintainers, make them and follow
this process again until the changes are merged in.

### Code Style

Please follow the coding style conventions detailed below:

#### Indentation

* Use 2 spaces.

in VIM you can use this settings:

```bash
set softtabstop=2
set shiftwidth=2
```

#### Functions

Good:

```bash
hosts_hello_world() {
  echo "Good!"
}
```

Bad: 

```bash
function hosts_hello_world() {
  echo "Bad"
}

hostsctl_hello_world()
{
  echo "Bad"
}
```

Please add a comment on top of the new function:

```bash
# hosts_hello_world: prints Hello, World to the screen.
hosts_hello_world() {
  echo "Hello, World!"
}
```

If this is a "core" function,
please add "hosts" before the new function name.

```bash
hosts_new_func_name() {
  echo "new function!"
}
```

#### Variables

Good: 

```bash
x="Hello"
echo "${x}"
```

Bad:

```bash
x="Hello"
echo $x
```

### Execute commands

Good

```bash
list_of_files=$(ls -a)

for file in ${list_of_files};do
  echo "FILE: $file"
done
```

Bad

```bash
list_of_files=`ls -a`

for file in $list_of_files:
  echo "FILE: $file"
done
```

# Text filtering

1. Use only `awk(1P)` to manipulate text.
2. do NOT use `sed(1)` (slow on large files!)
3. use `grep(1)`/`awk(1P)` for searching string/substring in a file.


that's it.

[1]: mailto:0xl3vi@gmail.com
[2]: https://github.com/0xl3vi/hostsctl/issues/new
[3]: https://github.com/0xl3vi/hostsctl/compare
[4]: https://github.com/0xl3vi/hostsctl/pulls
