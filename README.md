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

## README Overview

  - [Setup](https://github.com/favstats/peRspective#setup)
  - [Models](https://github.com/favstats/peRspective#models)
  - [Usage](https://github.com/favstats/peRspective#usage)
      - [`prsp_score`](https://github.com/favstats/peRspective#prsp_score)
      - [`prsp_stream`](https://github.com/favstats/peRspective#prsp_stream)

## Setup

### Get an API key

1.  Create a Google Cloud project in your [Google Cloud
    console](https://console.developers.google.com/)
2.  Go to [Perspective API’s overview
    page](https://console.developers.google.com/apis/api/commentanalyzer.googleapis.com/overview)
    and click **Enable**
3.  Go to the [API credentials
    page](https://console.developers.google.com/apis/credentials), just
    click **Create credentials**, and choose “API Key”.

Now you are ready to make a request to the Perspective API\!

### Quota and character length Limits

Be sure to check your quota limit\! You can learn more about Perspective
API quota limit by visiting [your google cloud project’s Perspective API
page](https://console.cloud.google.com/apis/api/commentanalyzer.googleapis.com/quotas).

The maximum text size per request is 3000 bytes.

## Models

For detailed overview of the used models [see
here](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md).

Here is a list of models currently supported by `peRspective`:

| Model Attribute Name  | Version                             | Supported Languages  | Short Description                                                                                   |
| :-------------------- | :---------------------------------- | :------------------- | :-------------------------------------------------------------------------------------------------- |
| TOXICITY              | Alpha                               | en, es, fr\*, de\*   | rude, disrespectful, or unreasonable comment that is likely to make people leave a discussion.      |
| SEVERE\_TOXICITY      | Alpha                               | en, es, fr\*, de\*   | Same deep-CNN algorithm as TOXICITY, but is trained on ‘very toxic’ labels.                         |
| IDENTITY\_ATTACK      | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | negative or hateful comments targeting someone because of their identity.                           |
| INSULT                | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | insulting, inflammatory, or negative comment towards a person or a group of people.                 |
| PROFANITY             | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | swear words, curse words, or other obscene or profane language.                                     |
| SEXUALLY\_EXPLICIT    | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | contains references to sexual acts, body parts, or other lewd content.                              |
| THREAT                | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | describes an intention to inflict pain, injury, or violence against an individual or group.         |
| FLIRTATION            | Experimental toxicity sub-attribute | en, fr\*, de\*, es\* | pickup lines, complimenting appearance, subtle sexual innuendos, etc.                               |
| ATTACK\_ON\_AUTHOR    | NYT moderation models               | en                   | Attack on the author of an article or post.                                                         |
| ATTACK\_ON\_COMMENTER | NYT moderation models               | en                   | Attack on fellow commenter.                                                                         |
| INCOHERENT            | NYT moderation models               | en                   | Difficult to understand, nonsensical.                                                               |
| INFLAMMATORY          | NYT moderation models               | en                   | Intending to provoke or inflame.                                                                    |
| LIKELY\_TO\_REJECT    | NYT moderation models               | en                   | Overall measure of the likelihood for the comment to be rejected according to the NYT’s moderation. |
| OBSCENE               | NYT moderation models               | en                   | Obscene or vulgar language such as cursing.                                                         |
| SPAM                  | NYT moderation models               | en                   | Irrelevant and unsolicited commercial content.                                                      |
| UNSUBSTANTIAL         | NYT moderation models               | en                   | Trivial or short comments.                                                                          |

**Note:** Languages that are annotated with "\*" are only accessible in
the `_EXPERIMENTAL` version of the models. In order to access them just
add to the supplied model string like this: `TOXICITY_EXPERIMENTAL`.

A character vector that includes all supported models can be obtained
like this:

``` r
c(
  peRspective::prsp_models,
  peRspective::prsp_exp_models
)
```

    ##  [1] "TOXICITY"                     "SEVERE_TOXICITY"             
    ##  [3] "IDENTITY_ATTACK"              "INSULT"                      
    ##  [5] "PROFANITY"                    "SEXUALLY_EXPLICIT"           
    ##  [7] "THREAT"                       "FLIRTATION"                  
    ##  [9] "ATTACK_ON_AUTHOR"             "ATTACK_ON_COMMENTER"         
    ## [11] "INCOHERENT"                   "INFLAMMATORY"                
    ## [13] "LIKELY_TO_REJECT"             "OBSCENE"                     
    ## [15] "SPAM"                         "UNSUBSTANTIAL"               
    ## [17] "TOXICITY_EXPERIMENTAL"        "SEVERE_TOXICITY_EXPERIMENTAL"
    ## [19] "IDENTITY_ATTACK_EXPERIMENTAL" "INSULT_EXPERIMENTAL"         
    ## [21] "PROFANITY_EXPERIMENTAL"       "THREAT_EXPERIMENTAL"

## Usage

First, install package from GitHub:

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

Define your key variable.

`peRspective` functions will read the API key from environment variable
`perspective_api_key`. You can assign an environment object like this in
your script:

``` r
Sys.setenv(perspective_api_key = "YOUR_API_KEY")
```

### `prsp_score`

Now you can use `prsp_score` to score your comments with various models
provided by the Perspective API.

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

Instead of scoring just entire comments you can also score individual
sentences with `score_sentences = T`. In this case the Perspective API
will automatically split your text into reasonable sentences and score
them in addition to an overall score.

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

You can also use Spanish (`es`) for `TOXICITY` and `SEVERE_TOXICITY`
scoring.

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

### `prsp_stream`

So far we have only seen how to get individual comments or sentences
scored. But what if you would like to run the function for an entire
dataset full text? This is where `prsp_stream` comes in. At its core
`prsp_stream` is a loop implemented within `purrr::map` to iterate over
your text column. To use it let’s first generate a mock tibble.

``` r
text_sample <- tibble(ctext = c("What the hell is going on?",
                 "Please no what I don't get it.",
                 "This goes even farther!",
                 "What the hell is going on?",
                 "Please no what I don't get it.",
                 "This goes even farther!"),
       textid = c("#efdcxct", "#ehfcsct", 
                  "#ekacxwt",  "#ewatxad", 
                  "#ekacswt",  "#ewftxwd"))
```

`prsp_stream` requires a `text` and `text_id column`. It wraps
`prsp_score` and takes all its arguments. Let’s run the most basic
version:

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY"))
```

    ## Binding rows...

    ## # A tibble: 6 x 3
    ##   text_id  TOXICITY SEVERE_TOXICITY
    ##   <chr>       <dbl>           <dbl>
    ## 1 #efdcxct   0.666           0.309 
    ## 2 #ehfcsct   0.0709          0.0288
    ## 3 #ekacxwt   0.0582          0.0221
    ## 4 #ewatxad   0.666           0.309 
    ## 5 #ekacswt   0.0709          0.0288
    ## 6 #ewftxwd   0.0582          0.0221

You receive a `tibble` with your desired scorings including the
`text_id` to match your score with your original dataframe.

Now, the problem is that sometimes the call might fail at some point. It
is therefore suggested to set `safe_output = TRUE`. This will put the
function into a `purrr::safely` environment to ensure that your function
will keep running even if you encounter errors.

Let’s try it out with a new dataset that contains text that the
Perspective API can’t score

``` r
text_sample <- tibble(ctext = c("What the hell is going on?",
                 "Please no what I don't get it.",
                 ## empty string
                 "",
                 "This goes even farther!",
                 "What the hell is going on?",
                 "Please no what I don't get it.",
                 ## Gibberish
                 "kdlfkmgkdfmgkfmg",
                 ## Gibberish
                 "This goes even farther!",
                 "Hippi Hoppo"),
       textid = c("#efdcxct", "#ehfcsct", 
                  "#ekacxwt",  "#ewatxad", 
                  "#ekacswt",  "#ewftxwd", 
                  "#ekacbwt",  "#ejatxwd", 
                  "dfdfgss"))
```

And run the function with `safe_output = TRUE`.

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY"),
              safe_output = T)
```

    ## # A tibble: 9 x 4
    ##   text_id  error                                   TOXICITY SEVERE_TOXICITY
    ##   <chr>    <chr>                                      <dbl>           <dbl>
    ## 1 #efdcxct No Error                                  0.666           0.309 
    ## 2 #ehfcsct No Error                                  0.0709          0.0288
    ## 3 #ekacxwt "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA     
    ## 4 #ewatxad No Error                                  0.0582          0.0221
    ## 5 #ekacswt No Error                                  0.666           0.309 
    ## 6 #ewftxwd No Error                                  0.0709          0.0288
    ## 7 #ekacbwt "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA     
    ## 8 #ejatxwd No Error                                  0.0582          0.0221
    ## 9 dfdfgss  "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA

`safe_output = T` will also provide us with the error messages that
occured so that we can check what went wrong\!

Finally, there is one last argument: `verbose = TRUE`. Enable this
argument and thanks to [`crayon`](https://github.com/r-lib/crayon) you
will receive beautiful console output that guides you along the way,
showing you errors and text scores as you go.

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY"),
              verbose = T,
              safe_output = T)
```

![](images/prsp_stream%20output.png)

Or the (not as pretty) output in Markdown

    ## 11.11% [2019-05-12 00:23:46]: 1 out of 9 (11.11%)
    ## text_id: #efdcxct
    ##  0.67 TOXICITY
    ##  0.31 SEVERE_TOXICITY
    ## 
    ## 22.22% [2019-05-12 00:23:47]: 2 out of 9 (22.22%)
    ## text_id: #ehfcsct
    ##  0.07 TOXICITY
    ##  0.03 SEVERE_TOXICITY
    ## 
    ## 33.33% [2019-05-12 00:23:49]: 3 out of 9 (33.33%)
    ## text_id: #ekacxwt
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Comment must be non-empty.
    ## NO SCORES
    ## 
    ## 44.44% [2019-05-12 00:23:50]: 4 out of 9 (44.44%)
    ## text_id: #ewatxad
    ##  0.06 TOXICITY
    ##  0.02 SEVERE_TOXICITY
    ## 
    ## 55.56% [2019-05-12 00:23:51]: 5 out of 9 (55.56%)
    ## text_id: #ekacswt
    ##  0.67 TOXICITY
    ##  0.31 SEVERE_TOXICITY
    ## 
    ## 66.67% [2019-05-12 00:23:52]: 6 out of 9 (66.67%)
    ## text_id: #ewftxwd
    ##  0.07 TOXICITY
    ##  0.03 SEVERE_TOXICITY
    ## 
    ## 77.78% [2019-05-12 00:23:53]: 7 out of 9 (77.78%)
    ## text_id: #ekacbwt
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Attribute SEVERE_TOXICITY does not support request languages: is
    ## NO SCORES
    ## 
    ## 88.89% [2019-05-12 00:23:54]: 8 out of 9 (88.89%)
    ## text_id: #ejatxwd
    ##  0.06 TOXICITY
    ##  0.02 SEVERE_TOXICITY
    ## 
    ## 100.00% [2019-05-12 00:23:55]: 9 out of 9 (100.00%)
    ## text_id: dfdfgss
    ## ERROR
    ## Error in .f(...): HTTP 400
    ## INVALID_ARGUMENT: Attribute SEVERE_TOXICITY does not support request languages: ja-Latn
    ## NO SCORES

    ## # A tibble: 9 x 4
    ##   text_id  error                                   TOXICITY SEVERE_TOXICITY
    ##   <chr>    <chr>                                      <dbl>           <dbl>
    ## 1 #efdcxct No Error                                  0.666           0.309 
    ## 2 #ehfcsct No Error                                  0.0709          0.0288
    ## 3 #ekacxwt "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA     
    ## 4 #ewatxad No Error                                  0.0582          0.0221
    ## 5 #ekacswt No Error                                  0.666           0.309 
    ## 6 #ewftxwd No Error                                  0.0709          0.0288
    ## 7 #ekacbwt "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA     
    ## 8 #ejatxwd No Error                                  0.0582          0.0221
    ## 9 dfdfgss  "Error in .f(...): HTTP 400\nINVALID_A~  NA              NA
