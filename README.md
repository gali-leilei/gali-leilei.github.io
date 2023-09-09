# personal website using zola

[zola documentation](http://getzola.org)

# common task

## add image

use shortcodes (think it like react component) `{{ resize_image(...) }}`

## add links to static assets

todo

## publish to bitbucket

assume the following file structure:

```bash
.
├── galileilei.bitbucket.io  # where bitbucket will publish
└── zola-demo                # this repo
```

then run the following command:

```bash
cd zola-demo/
zola build
cp -r public/* ../galileilei.bitbucket.io/.
cd ../galileilei.bitbucket.io/
git add .
git commit -m "new version"
git push -u origin master
```