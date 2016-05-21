# Repol

Repol is a tool to manage [ECR Repository Policy](http://docs.aws.amazon.com/AmazonECR/latest/userguide/RepositoryPolicies.html).

It defines the state of ECR Repository Policy using DSL, and updates ECR Repository Policy according to DSL.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'repol'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install repol

## Usage

```sh
export AWS_ACCESS_KEY_ID='...'
export AWS_SECRET_ACCESS_KEY='...'
repol -e -o RepolFile  # export Repository Policy
vi RepolFile
repol -a --dry-run
repol -a               # apply `RepolFile`
```

## Help

```
Usage: repol [options]
    -k, --access-key ACCESS_KEY
    -s, --secret-key SECRET_KEY
    -r, --region REGION
        --profile PROFILE
        --credentials-path PATH
    -a, --apply
    -f, --file FILE
        --dry-run
    -e, --export
    -o, --output FILE
        --split
        --target REGEXP
        --no-color
        --debug
        --request-concurrency N
```

## RepolFile example

```ruby
require 'other/RepolFile'

repository "my_ecr_repo" do
  {"Version"=>"2008-10-17",
   "Statement"=>
    [{"Sid"=>"PullOnly",
      "Effect"=>"Allow",
      "Principal"=>{"AWS"=>"arn:aws:iam::123456789012:root"},
      "Action"=>
       ["ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:GetDownloadUrlForLayer"]}]}
end
```
