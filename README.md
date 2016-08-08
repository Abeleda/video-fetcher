# Video Platform

The main idea of this project is to fetch all videos' metadata from three popular social networks:
  - Facebook
  - YouTube
  - Vimeo

To configure the project, copy `credentials.json.example` to `credentials.json` and paste your API keys into corresponding JSON fields.

We are collecting following metadata:
  - duration
  - likes
  - views
  - dislikes
  - comments
  - shares.

To work with each of social networks we use the following solution:
 - Facebook: Graph API with [Koala](https://github.com/arsduo/koala) gem.
 - YouTube: [Yt](https://github.com/Fullscreen/yt) gem.
 - Video: since we didn't find a good gem for it, we've written a client ourselves.

Interaction with Facebook was tricky because FB increases response time when someone starts sending a lot of requests in the short period of time. To bypass it, we've optimized our fetch algorithm to work with Facebook using several API keys in a moment.

The project has also an admin part written with [ActiveAdmin](https://github.com/activeadmin/activeadmin) gem. It is used to watch the results of fetching videos and metadata.

## Requirements
 - Rails 4
 - PostgreSQL

## License

The MIT License (MIT)

Copyright (c) 2016 Codica

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.