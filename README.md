# Video Platform
 
 The main idea of this project is to fetch all videos' metadata from three popular social networks: **_Facebook_**, **_YouTube_**, **_Vimeo_**.
 
 To configure the project, copy `credentials.json.example` to `credentials.json` and paste your API keys into corresponding JSON fields.
 
 For **_Facebook_** we are using **Graph API** with **Koala** gem. For **_YouTube_**, the **Yt** gem is used. Since we didn't find a good gem for interaction with **_Vimeo_**, we had to write a client for it ourselves.
 
 We are collecting following metadata: duration, likes, views, dislikes, comments and shares.
 
 We had most issues with **_Facebook_**: when a large sequence of requests is sent to it, Facebook increases response time. To bypass it, we had to optimize a fetch algorithm.
 
 The project has also an admin part written with **_ActiveAdmin_** gem. It is used to watch the results of fetching videos and metadata.