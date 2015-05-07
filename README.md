# tm-qa-azure
TM QA Size in Azure

**commands to create size in Azure cli**

azure site create --location "North Europe" --github --githubusername "tm-build" --githubpassword {personal-access-token} --githubrepository tm-build/tm-qa-azure tm-qa-6 

azure site appsetting add git_pwd={personal-access-token} tm-qa-6

