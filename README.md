# image_archive.yazi 

Plugin for yazi filer to preview images in the archive.

this plugin supports linux only.

## Requirements
- unar

## Usage

```toml
[plugin]
prepend_previewers = [
  { name = "*.zip", exec = "image_archive" },
]
```
