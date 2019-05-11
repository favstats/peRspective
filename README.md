peRspective
================

<!-- [![Travis build status](https://travis-ci.org/favstats/peRspective.svg?branch=master)](https://travis-ci.org/favstats/peRspective) -->

[![](https://img.shields.io/github/languages/code-size/favstats/peRspective.svg)](https://github.com/favstats/peRspective)
[![](https://img.shields.io/github/last-commit/favstats/peRspective.svg)](https://github.com/favstats/peRspective/commits/master)

Perspective is an API that uses machine learning models to score the
perceived impact a comment might have on a conversation.
[Website](http://www.perspectiveapi.com/).

`peRspective` provides access to the API using the R programming
language.

For an excellent documentation of the Perspective API see
[here](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md).

## Setup

### API authorization

In order to get the Perspective API working you need to create a Google
Cloud project in your [Google Cloud
console](https://console.developers.google.com/). You can also use an
existing project, if you have one.

Once you have a project set up go to [Perspective API’s overview
page](https://console.developers.google.com/apis/api/commentanalyzer.googleapis.com/overview)
and click ***Enable***.

Finally, you need to obtain an API key. You can do this on the [API
credentials
page](https://console.developers.google.com/apis/credentials), just
click ***Create credentials***, and choose “API Key”. Story your API key
safely.

Now you are ready to make a request to the Perspective API\!

### Quota and character length Limits

You can check your quota limits by going to [your google cloud project’s
Perspective API
page](https://console.cloud.google.com/apis/api/commentanalyzer.googleapis.com/quotas),
and check your projects quota usage at [the cloud console quota usage
page](https://console.cloud.google.com/iam-admin/quotas).

The maximum text size per request is 3000 bytes.

### In R

Install package from GitHub:

``` r
devtools::install_github("favstats/peRspective")
```

Load package:

``` r
library(peRspective)
```

Also the `tidyverse` for examples.

``` r
library(tidyverse)
```

## Models

### Alpha

The following alpha models are **recommended** for use. They have been
tested across multiple domains and trained on hundreds of thousands of
comments tagged by thousands of human moderators. These are available in
**English (en) and Spanish (es)**.

  - **TOXICITY**: rude, disrespectful, or unreasonable comment that is
    likely to make people leave a discussion. This model is a
    [Convolutional Neural
    Network](https://en.wikipedia.org/wiki/Convolutional_neural_network)
    (CNN) trained with
    [word-vector](https://www.tensorflow.org/tutorials/word2vec) inputs.
  - **SEVERE\_TOXICITY**: This model uses the same deep-CNN algorithm as
    the TOXICITY model, but is trained to recognise examples that were
    considered to be ‘very toxic’ by crowdworkers. This makes it much
    less sensitive to comments that include positive uses of curse-words
    for example. A labelled dataset and details of the methodolgy can be
    found in the same [toxicity
    dataset](https://figshare.com/articles/Wikipedia_Talk_Labels_Toxicity/4563973)
    that is available for the toxicity model.

### Experimental

#### Experimental toxicity sub-attributes definitions

The following experimental models give more fine-grained classifications
than overall toxicity. They were trained on a relatively smaller amount
of data compared to the primary toxicity models above and have not been
tested as thoroughly.

  - **IDENTITY\_ATTACK**: negative or hateful comments targeting someone
    because of their identity.
  - **INSULT**: insulting, inflammatory, or negative comment towards a
    person or a group of people.
  - **PROFANITY**: swear words, curse words, or other obscene or profane
    language.
  - **THREAT**: describes an intention to inflict pain, injury, or
    violence against an individual or group.
  - **SEXUALLY\_EXPLICIT**: contains references to sexual acts, body
    parts, or other lewd content.
  - **FLIRTATION**: pickup lines, complimenting appearance, subtle
    sexual innuendos, etc.

For more details on how these were trained, see the [Toxicity and
sub-attribute annotation
guidelines](https://github.com/conversationai/conversationai.github.io/blob/master/crowdsourcing_annotation_schemes/toxicity_with_subattributes.md).

### New York Times moderation models

The following experimental models were trained on New York Times data
tagged by their moderation team.

  - **ATTACK\_ON\_AUTHOR**: Attack on the author of an article or post.
  - **ATTACK\_ON\_COMMENTER**: Attack on fellow commenter.
  - **INCOHERENT**: Difficult to understand, nonsensical.
  - **INFLAMMATORY**: Intending to provoke or inflame.
  - **LIKELY\_TO\_REJECT**: Overall measure of the likelihood for the
    comment to be rejected according to the NYT’s moderation.
  - **OBSCENE**: Obscene or vulgar language such as cursing.
  - **SPAM**: Irrelevant and unsolicited commercial content.
  - **UNSUBSTANTIAL**: Trivial or short comments.

Here is a list of currently supported models:

| Model Attribute Name  | Version                             | Supported Languages |
| :-------------------- | :---------------------------------- | :------------------ |
| TOXICITY              | Alpha                               | en, es              |
| SEVERE\_TOXICITY      | Alpha                               | en, es              |
| IDENTITY\_ATTACK      | Experimental toxicity sub-attribute | en                  |
| INSULT                | Experimental toxicity sub-attribute | en                  |
| PROFANITY             | Experimental toxicity sub-attribute | en                  |
| SEXUALLY\_EXPLICIT    | Experimental toxicity sub-attribute | en                  |
| THREAT                | Experimental toxicity sub-attribute | en                  |
| FLIRTATION            | Experimental toxicity sub-attribute | en                  |
| ATTACK\_ON\_AUTHOR    | NYT moderation models               | en                  |
| ATTACK\_ON\_COMMENTER | NYT moderation models               | en                  |
| INCOHERENT            | NYT moderation models               | en                  |
| INFLAMMATORY          | NYT moderation models               | en                  |
| LIKELY\_TO\_REJECT    | NYT moderation models               | en                  |
| OBSCENE               | NYT moderation models               | en                  |
| SPAM                  | NYT moderation models               | en                  |
| UNSUBSTANTIAL         | NYT moderation models               | en                  |

A character vector that includes all supported models can be obtained
like this:

``` r
peRspective::prsp_models
```

    ##  [1] "TOXICITY"            "SEVERE_TOXICITY"     "IDENTITY_ATTACK"    
    ##  [4] "INSULT"              "PROFANITY"           "SEXUALLY_EXPLICIT"  
    ##  [7] "THREAT"              "FLIRTATION"          "ATTACK_ON_AUTHOR"   
    ## [10] "ATTACK_ON_COMMENTER" "INCOHERENT"          "INFLAMMATORY"       
    ## [13] "LIKELY_TO_REJECT"    "OBSCENE"             "SPAM"               
    ## [16] "UNSUBSTANTIAL"

## Usage

First, define your key variable.

`peRspective` functions will read the API key from environment variable
`perspective_api_key`. You can assign an environment object like this in
your script:

``` r
Sys.setenv(perspective_api_key = "YOUR_API_KEY")
```

Next, you can use `prsp_score` to score your comments with various
models provided by the Perspective API.

``` r
my_text <- "Hello whats going on? Please don't leave. I need to be free."

text_scores <- prsp_score(
           text = my_text, 
           languages = "en",
           score_model = peRspective::prsp_models
           )

text_scores %>% 
  gather() %>% 
  mutate(key = fct_reorder(key, value)) %>% 
  ggplot(aes(key, value)) +
  geom_col() +
  coord_flip()
```

![](README_files/figure-gfm/unnamed-chunk-9-1.png)<!-- -->

A Trump Tweet

``` r
trump_tweet <- "The Fake News Media has NEVER been more Dishonest or Corrupt than it is right now. There has never been a time like this in American History. Very exciting but also, very sad! Fake News is the absolute Enemy of the People and our Country itself!"

text_scores <- prsp_score(
           trump_tweet, 
           score_sentences = F,
           score_model = peRspective::prsp_models
           )

text_scores %>% 
  gather() %>% 
  mutate(key = fct_reorder(key, value)) %>% 
  ggplot(aes(key, value)) +
  geom_col() +
  coord_flip()
```

![](README_files/figure-gfm/unnamed-chunk-10-1.png)<!-- -->

Let’s try something else:

``` r
trump_tweet <- "The Fake News Media has NEVER been more Dishonest or Corrupt than it is right now. There has never been a time like this in American History. Very exciting but also, very sad! Fake News is the absolute Enemy of the People and our Country itself!"

text_scores <- prsp_score(
           trump_tweet, 
           score_sentences = T,
           score_model = peRspective::prsp_models
           )

text_scores %>% 
  unnest(sentence_scores) %>% 
  select(type, score, sentences) %>% 
  gather(value, key, -sentences, -score) %>% 
  mutate(key = fct_reorder(key, score)) %>% 
  ggplot(aes(key, score)) +
  geom_col() +
  coord_flip() +
  facet_wrap(~sentences, ncol = 2) +
  theme_minimal() +
  geom_hline(yintercept = 0.5, linetype = "dashed")
```

![](README_files/figure-gfm/unnamed-chunk-11-1.png)<!-- -->

``` r
spanish_text <- "Con la llegado de internet y de las nuevas tecnologías de la información, la forma de contactar que tenemos entre los seres humanos ha cambiado y lo va a seguir haciendo en un futuro no muy lejano."


text_scores <- prsp_score(
           text = spanish_text, 
           languages = "es",
           key = key,
           score_model = c("TOXICITY", "SEVERE_TOXICITY")
           )

text_scores %>% 
  gather() %>% 
  mutate(key = fct_reorder(key, value)) %>% 
  ggplot(aes(key, value)) +
  geom_col() +
  coord_flip()
```

![](README_files/figure-gfm/unnamed-chunk-12-1.png)<!-- -->

## `prsp_stream`

``` r
text_sample <- tibble(ctext = c("What the hell is going on?",
                 "Please no what I don't get it.",
                 "",
                 "This goes even farther!",
                 "What the hell is going on?",
                 "Please no what I don't get it.",
                 "kdlfkmgkdfmgkfmg",
                 "This goes even farther!",
                 "Hippi Hoppo"),
       textid = c("#efdcxct", "#ehfcsct", 
                  "#ekacxwt",  "#ewatxad", 
                  "#ekacswt",  "#ewftxwd", 
                  "#ekacbwt",  "#ejatxwd", 
                  "dfdfgss"))
```

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY"),
              score_sentences  = T,
              verbose = T,
              safe_output = T)
```

    ## 11.11% [2019-05-11 21:24:20]: 1 out of 9 (11.11%)
    ## text_id: #efdcxct
    ##  0.67 TOXICITY
    ##  0.31 SEVERE_TOXICITY
    ## 
    ## 22.22% [2019-05-11 21:24:21]: 2 out of 9 (22.22%)
    ## text_id: #ehfcsct
    ##  0.07 TOXICITY
    ##  0.03 SEVERE_TOXICITY
    ## 
    ## 33.33% [2019-05-11 21:24:22]: 3 out of 9 (33.33%)
    ## text_id: #ekacxwt
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Comment must be non-empty.
    ## NO SCORES
    ## 
    ## 44.44% [2019-05-11 21:24:23]: 4 out of 9 (44.44%)
    ## text_id: #ewatxad
    ##  0.06 TOXICITY
    ##  0.02 SEVERE_TOXICITY
    ## 
    ## 55.56% [2019-05-11 21:24:24]: 5 out of 9 (55.56%)
    ## text_id: #ekacswt
    ##  0.67 TOXICITY
    ##  0.31 SEVERE_TOXICITY
    ## 
    ## 66.67% [2019-05-11 21:24:25]: 6 out of 9 (66.67%)
    ## text_id: #ewftxwd
    ##  0.07 TOXICITY
    ##  0.03 SEVERE_TOXICITY
    ## 
    ## 77.78% [2019-05-11 21:24:26]: 7 out of 9 (77.78%)
    ## text_id: #ekacbwt
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Attribute SEVERE_TOXICITY does not support request languages: is
    ## NO SCORES
    ## 
    ## 88.89% [2019-05-11 21:24:27]: 8 out of 9 (88.89%)
    ## text_id: #ejatxwd
    ##  0.06 TOXICITY
    ##  0.02 SEVERE_TOXICITY
    ## 
    ## 100.00% [2019-05-11 21:24:29]: 9 out of 9 (100.00%)
    ## text_id: dfdfgss
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Attribute SEVERE_TOXICITY does not support request languages: ja-Latn
    ## NO SCORES

    ## # A tibble: 15 x 7
    ##    text_id  error        summary_score spans type   sentence_scores text   
    ##    <chr>    <chr>                <dbl> <int> <chr>  <list>          <chr>  
    ##  1 #efdcxct No Error            0.666      1 TOXIC~ <tibble [1 x 4~ What t~
    ##  2 #efdcxct No Error            0.309      1 SEVER~ <tibble [1 x 4~ What t~
    ##  3 #ehfcsct No Error            0.0709     1 TOXIC~ <tibble [1 x 4~ Please~
    ##  4 #ehfcsct No Error            0.0288     1 SEVER~ <tibble [1 x 4~ Please~
    ##  5 #ekacxwt "Error in .~       NA         NA <NA>   <NULL>          <NA>   
    ##  6 #ewatxad No Error            0.0582     1 TOXIC~ <tibble [1 x 4~ This g~
    ##  7 #ewatxad No Error            0.0221     1 SEVER~ <tibble [1 x 4~ This g~
    ##  8 #ekacswt No Error            0.666      1 TOXIC~ <tibble [1 x 4~ What t~
    ##  9 #ekacswt No Error            0.309      1 SEVER~ <tibble [1 x 4~ What t~
    ## 10 #ewftxwd No Error            0.0709     1 TOXIC~ <tibble [1 x 4~ Please~
    ## 11 #ewftxwd No Error            0.0288     1 SEVER~ <tibble [1 x 4~ Please~
    ## 12 #ekacbwt "Error in .~       NA         NA <NA>   <NULL>          <NA>   
    ## 13 #ejatxwd No Error            0.0582     1 TOXIC~ <tibble [1 x 4~ This g~
    ## 14 #ejatxwd No Error            0.0221     1 SEVER~ <tibble [1 x 4~ This g~
    ## 15 dfdfgss  "Error in .~       NA         NA <NA>   <NULL>          <NA>
