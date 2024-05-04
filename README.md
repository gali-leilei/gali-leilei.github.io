# personal website using zola

[zola documentation](http://getzola.org)

# FAQ

## how to preview locally?

```bash
zola serve # serve the site @ `127.0.0.1:1111`
```

check out [zola cli usage](https://www.getzola.org/documentation/getting-started/cli-usage/)


## how to add a new post?

to add a post under route `/foo/bar/new-post`:

```bash
mkdir -p /content/foo/bar
cd /content/foo/bar
touch new-post.md
```

the markdown file should have the following front-matter:

```ini
+++
title = "whatever"
date = 2023-11-02
template = "markdown-page.html"
+++
```

What happens behind the scene? As far as I can tell:
- zola parses `new-post.md` into a struct, say `page`, where
    - frontmatter --> key-value attributes of `page`, so `page.title = "whatever"`, `page.data = 2023-11-02`
    - the main content --> `page.content`
- zola loads the Jinja template under `./templates/markdown-page.html` (specified in `page.template`), and hydrate it with `page`.
- zola outputs a server-side rendered, static HTML page, under `./public/foo/bar/new-post.html`.
- This page is saved and served on `0.0.0.0:1111/foo/bar/new-post`.


check out [zolo page documentation](https://www.getzola.org/documentation/content/page/)

## how to add image to post?

use shortcodes (think it like react component) `{{ resize_image(...) }}`

## how to style a component?

zola uses scss to style, so:

- a html element `<xxx > ... </xxx>` will be styled by `xxx { ...}` in some `.scss` file.
- a html element `<div class="xxx__yyy"> ... </div>` will be styled by `.xxx { &__yyy {...}}` in some `.scss` file.


## how to add links to static assets?

## how to link to other pages?

Use [interal link](https://www.getzola.org/documentation/content/linking/#internal-links).


## how to publish to bitbucket?

Bitbucket supports personal website, see [link here](https://support.atlassian.com/bitbucket-cloud/docs/publishing-a-website-on-bitbucket-cloud/). A repo is consider a personal website iff:
1. It has `index.html` under the root.
2. Its url is `<workspace-ID>.bitbucket.io`

Assume the following file structure:

```bash
.
├── galileilei.bitbucket.io  # where bitbucket will publish
└── zola-galileilei          # this repo
```

then run the following command:

```bash
cd zola-galileilei/
zola build # build the whole site in the `/public` directory 
cp -r public/* ../galileilei.bitbucket.io/.
cd ../galileilei.bitbucket.io/
git add .
git commit -m "new version"
git push -u origin master
```