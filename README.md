<div align="center">
        <p> <img src="https://i.imgur.com/xRvoaDG.png"/> </p>
        <p><i><b>A simple solution to create Discord bots using Julia</b></i></p>
</div>

## Julicord

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://PurgePJ.github.io/Julicord/stable)
[![Latest](https://img.shields.io/badge/docs-latest-blue.svg)](https://PurgePJ.github.io/Julicord/latest)
[![Build Status](https://travis-ci.com/PurgePJ/Julicord.svg?branch=master)](https://travis-ci.com/PurgePJ/Julicord)
[![CodeCov](https://codecov.io/gh/PurgePJ/Julicord/branch/master/graph/badge.svg)](https://codecov.io/gh/PurgePJ/Julicord)

### Bot Sample

```julia
using Julicord

c = Client("token")
add_handler!(c, MessageDelete, e -> println("message $(e.id) was deleted"))
open(c)
wait(c)
```
