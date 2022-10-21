
### Add Original
```
vim .git/config

[remote "original"]
    url = git@github.com:unegma/aws-api-backend.git
    fetch = +refs/heads/*:refs/remotes/origin/*
    
git pull original master --allow-unrelated-histories
```
