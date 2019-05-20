
<!-- README.md is generated from README.Rmd. Please edit that file -->

# peRspective <img src="man/figures/perspective.png" width="160px" align="right" />

![](https://img.shields.io/badge/My%201st%20Package-Ever-blue.svg)
[![](https://travis-ci.org/favstats/peRspective.svg?branch=master)](https://travis-ci.org/favstats/peRspective)
[![](https://www.r-pkg.org/badges/version/peRspective?color=blue)](https://cran.r-project.org/package=peRspective)
[![Codecov test
coverage](https://codecov.io/gh/favstats/peRspective/branch/master/graph/badge.svg)](https://codecov.io/gh/favstats/peRspective?branch=master)
[![](https://img.shields.io/github/languages/code-size/favstats/peRspective.svg)](https://github.com/favstats/peRspective)
[![](https://img.shields.io/github/last-commit/favstats/peRspective.svg)](https://github.com/favstats/peRspective/commits/master)

Perspective is an API that uses machine learning models to score the
perceived impact a comment might have on a conversation.
[Website](http://www.perspectiveapi.com/).

`peRspective` provides access to the API using the R programming
language.

For an excellent documentation of the Perspective API see
[here](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md).

> This is a work-in-progress project and I welcome feedback and pull
> requests\!

## Overview

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
#>  [1] "TOXICITY"                     "SEVERE_TOXICITY"             
#>  [3] "IDENTITY_ATTACK"              "INSULT"                      
#>  [5] "PROFANITY"                    "SEXUALLY_EXPLICIT"           
#>  [7] "THREAT"                       "FLIRTATION"                  
#>  [9] "ATTACK_ON_AUTHOR"             "ATTACK_ON_COMMENTER"         
#> [11] "INCOHERENT"                   "INFLAMMATORY"                
#> [13] "LIKELY_TO_REJECT"             "OBSCENE"                     
#> [15] "SPAM"                         "UNSUBSTANTIAL"               
#> [17] "TOXICITY_EXPERIMENTAL"        "SEVERE_TOXICITY_EXPERIMENTAL"
#> [19] "IDENTITY_ATTACK_EXPERIMENTAL" "INSULT_EXPERIMENTAL"         
#> [21] "PROFANITY_EXPERIMENTAL"       "THREAT_EXPERIMENTAL"
```

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

**Define your key variable.**

`peRspective` functions will read the API key from environment variable
`perspective_api_key`. In order to add your key to your environment
file, you can use the function `edit_r_environ()` from the [`usethis`
package](https://usethis.r-lib.org/).

``` r
usethis::edit_r_environ()
```

This will open your .Renviron file in your text editor. Now, you can add
the following line to it:

``` r
perspective_api_key="YOUR_API_KEY"
```

Save the file and restart R for the changes to take effect.

Alternatively, you can provide an explicit definition of your API key
with each function call using the `key` argument.

### `prsp_score`

Now you can use `prsp_score` to score your comments with various models
provided by the Perspective API.

``` r

my_text <- "You wrote this? Wow. This is dumb and childish, please go f**** yourself."

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
  coord_flip() +
  ylim(0, 1) +
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  labs(x = "Model", y = "Probability", title = "Perspective API Results")
```

<img src="man/figures/README-unnamed-chunk-10-1.png" width="100%" />

A Trump Tweet:

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
  coord_flip() +
  ylim(0, 1) +
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  labs(x = "Model", y = "Probability", title = "Perspective API Results")
```

<img src="man/figures/README-unnamed-chunk-12-1.png" width="100%" />

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
  geom_hline(yintercept = 0.5, linetype = "dashed") +
  labs(x = "Model", y = "Probability", title = "Perspective API Results")
```

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

You can also use Spanish (`es`) for `TOXICITY`, `SEVERE_TOXICITY` and
`_EXPERIMENTAL` models.

``` r
spanish_text <- "gastan en cosas que de nada sirven-nunca tratan de saber la verdad del funcionalismo de nuestro sistema solar y origen del cosmos-falso por Kepler. LAS UNIVERSIDADES DEL MUNDO NO SABEN ANALIZAR VERDAD O MENTIRA-LO QUE DICE KEPLER"


text_scores <- prsp_score(
           text = spanish_text, 
           languages = "es",
           score_model = c("TOXICITY", "SEVERE_TOXICITY", "INSULT_EXPERIMENTAL")
           )

text_scores %>% 
  gather() %>% 
  mutate(key = fct_reorder(key, value)) %>% 
  ggplot(aes(key, value)) +
  geom_col() +
  coord_flip() +
  geom_hline(yintercept = 0.5, linetype = "dashed")  +
  labs(x = "Model", y = "Probability", title = "Perspective API Results")
```

<img src="man/figures/README-unnamed-chunk-16-1.png" width="100%" />

**NOTE:** Your provided text will be stored by the Perspective API for
future research. This option is the default. If the supplied texts are
private or any of the authors of the texts are below 13 years old,
`doNotStore` should be set to `TRUE.`

### `prsp_stream`

So far we have only seen how to get individual comments or sentences
scored. But what if you would like to run the function for an entire
dataset with a text column? This is where `prsp_stream` comes in. At its
core `prsp_stream` is a loop implemented within `purrr::map` to iterate
over your text column. To use it let’s first generate a mock tibble.

``` r
text_sample <- tibble(
       ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
                 "I don't know what to say about this but it's not good. The commenter is just an idiot",
                 "This goes even further!",
                 "What the hell is going on?",
                 "Please. I don't get it. Explain it again",
                 "Annoying and irrelevant! I'd rather watch the paint drying on the wall!"),
       textid = c("#efdcxct", "#ehfcsct", 
                  "#ekacxwt",  "#ewatxad", 
                  "#ekacswt",  "#ewftxwd")
       )
```

`prsp_stream` requires a `text` and `text_id column`. It wraps
`prsp_score` and takes all its arguments. Let’s run the most basic
version:

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY"))
#> Binding rows...
#> # A tibble: 6 x 3
#>   text_id  TOXICITY SEVERE_TOXICITY
#>   <chr>       <dbl>           <dbl>
#> 1 #efdcxct   0.955           0.794 
#> 2 #ehfcsct   0.927           0.436 
#> 3 #ekacxwt   0.0562          0.0224
#> 4 #ewatxad   0.666           0.309 
#> 5 #ekacswt   0.0694          0.0290
#> 6 #ewftxwd   0.442           0.224
```

You receive a `tibble` with your desired scorings including the
`text_id` to match your score with your original dataframe.

Now, the problem is that sometimes the call might fail at some point. It
is therefore suggested to set `safe_output = TRUE`. This will put the
function into a `purrr::safely` environment to ensure that your function
will keep running even if you encounter errors.

Let’s try it out with a new dataset that contains text that the
Perspective API can’t score

``` r
text_sample <- tibble(
       ctext = c("You wrote this? Wow. This is dumb and childish, please go f**** yourself.",
                 "I don't know what to say about this but it's not good. The commenter is just an idiot",
                 ## empty string
                 "",
                 "This goes even further!",
                 "What the hell is going on?",
                 "Please. I don't get it. Explain it again",
                 ## Gibberish
                 "kdlfkmgkdfmgkfmg",
                 "Annoying and irrelevant! I'd rather watch the paint drying on the wall!",
                 ## Gibberish
                 "Hippi Hoppo"),
       textid = c("#efdcxct", "#ehfcsct", 
                  "#ekacxwt",  "#ewatxad", 
                  "#ekacswt",  "#ewftxwd", 
                  "#eeadswt",  "#enfhxed",
                  "#efdmjd")
       )
```

And run the function with `safe_output = TRUE`.

``` r
text_sample %>%
  prsp_stream(text = ctext,
              text_id = textid,
              score_model = c("TOXICITY", "SEVERE_TOXICITY", "INSULT"),
              safe_output = T)
#> # A tibble: 9 x 5
#>   text_id  error                           TOXICITY SEVERE_TOXICITY  INSULT
#>   <chr>    <chr>                              <dbl>           <dbl>   <dbl>
#> 1 #efdcxct No Error                          0.955           0.794   0.923 
#> 2 #ehfcsct No Error                          0.927           0.436   0.947 
#> 3 #ekacxwt "Error in .f(...): HTTP 400\nI…  NA              NA      NA     
#> 4 #ewatxad No Error                          0.0562          0.0224  0.0315
#> 5 #ekacswt No Error                          0.666           0.309   0.331 
#> 6 #ewftxwd No Error                          0.0694          0.0290  0.0499
#> 7 #eeadswt "Error in .f(...): HTTP 400\nI…  NA              NA      NA     
#> 8 #enfhxed No Error                          0.442           0.224   0.321 
#> 9 #efdmjd  "Error in .f(...): HTTP 400\nI…  NA              NA      NA
```

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

![](man/figures/prsp_stream_output.png)

Or the (not as pretty) output in Markdown

    #> 11.11% [2019-05-20 14:24:16]: 1 out of 9 (11.11%)
    #> text_id: #efdcxct
    #>  0.96 TOXICITY
    #>  0.79 SEVERE_TOXICITY
    #> 
    #> 22.22% [2019-05-20 14:24:17]: 2 out of 9 (22.22%)
    #> text_id: #ehfcsct
    #>  0.93 TOXICITY
    #>  0.44 SEVERE_TOXICITY
    #> 
    #> 33.33% [2019-05-20 14:24:19]: 3 out of 9 (33.33%)
    #> text_id: #ekacxwt
    #> ERROR
    #> Error in .f(...): HTTP 400
    #> INVALID_ARGUMENT: Comment must be non-empty.
    #> NO SCORES
    #> 
    #> 44.44% [2019-05-20 14:24:20]: 4 out of 9 (44.44%)
    #> text_id: #ewatxad
    #>  0.06 TOXICITY
    #>  0.02 SEVERE_TOXICITY
    #> 
    #> 55.56% [2019-05-20 14:24:21]: 5 out of 9 (55.56%)
    #> text_id: #ekacswt
    #>  0.67 TOXICITY
    #>  0.31 SEVERE_TOXICITY
    #> 
    #> 66.67% [2019-05-20 14:24:22]: 6 out of 9 (66.67%)
    #> text_id: #ewftxwd
    #>  0.07 TOXICITY
    #>  0.03 SEVERE_TOXICITY
    #> 
    #> 77.78% [2019-05-20 14:24:23]: 7 out of 9 (77.78%)
    #> text_id: #eeadswt
    #> ERROR
    #> Error in .f(...): HTTP 400
    #> INVALID_ARGUMENT: Attribute TOXICITY does not support request languages: is
    #> NO SCORES
    #> 
    #> 88.89% [2019-05-20 14:24:24]: 8 out of 9 (88.89%)
    #> text_id: #enfhxed
    #>  0.44 TOXICITY
    #>  0.22 SEVERE_TOXICITY
    #> 
    #> 100.00% [2019-05-20 14:24:25]: 9 out of 9 (100.00%)
    #> text_id: #efdmjd
    #> ERROR
    #> Error in .f(...): HTTP 400
    #> INVALID_ARGUMENT: Attribute SEVERE_TOXICITY does not support request languages: ja-Latn
    #> NO SCORES
    #> # A tibble: 9 x 4
    #>   text_id  error                                   TOXICITY SEVERE_TOXICITY
    #>   <chr>    <chr>                                      <dbl>           <dbl>
    #> 1 #efdcxct No Error                                  0.955           0.794 
    #> 2 #ehfcsct No Error                                  0.927           0.436 
    #> 3 #ekacxwt "Error in .f(...): HTTP 400\nINVALID_A…  NA              NA     
    #> 4 #ewatxad No Error                                  0.0562          0.0224
    #> 5 #ekacswt No Error                                  0.666           0.309 
    #> 6 #ewftxwd No Error                                  0.0694          0.0290
    #> 7 #eeadswt "Error in .f(...): HTTP 400\nINVALID_A…  NA              NA     
    #> 8 #enfhxed No Error                                  0.442           0.224 
    #> 9 #efdmjd  "Error in .f(...): HTTP 400\nINVALID_A…  NA              NA

``` r
sessionInfo()
#> R version 3.6.0 (2019-04-26)
#> Platform: x86_64-w64-mingw32/x64 (64-bit)
#> Running under: Windows 10 x64 (build 17134)
#> 
#> Matrix products: default
#> 
#> locale:
#> [1] LC_COLLATE=English_Germany.1252  LC_CTYPE=English_Germany.1252   
#> [3] LC_MONETARY=English_Germany.1252 LC_NUMERIC=C                    
#> [5] LC_TIME=English_Germany.1252    
#> 
#> attached base packages:
#> [1] stats     graphics  grDevices utils     datasets  methods   base     
#> 
#> other attached packages:
#>  [1] peRspective_0.1.0 forcats_0.4.0     stringr_1.4.0    
#>  [4] dplyr_0.8.0.1     purrr_0.3.2       readr_1.3.1      
#>  [7] tidyr_0.8.3       tibble_2.1.1      ggplot2_3.1.1    
#> [10] tidyverse_1.2.1   badger_0.0.4     
#> 
#> loaded via a namespace (and not attached):
#>  [1] tidyselect_0.2.5   xfun_0.7           haven_2.1.0       
#>  [4] lattice_0.20-38    vctrs_0.1.0        colorspace_1.4-1  
#>  [7] generics_0.0.2     htmltools_0.3.6    yaml_2.2.0        
#> [10] utf8_1.1.4         rlang_0.3.4        pillar_1.4.0      
#> [13] withr_2.1.2        glue_1.3.1         RColorBrewer_1.1-2
#> [16] modelr_0.1.4       readxl_1.3.1       rvcheck_0.1.3     
#> [19] plyr_1.8.4         dlstats_0.1.0      munsell_0.5.0     
#> [22] gtable_0.3.0       cellranger_1.1.0   rvest_0.3.3       
#> [25] evaluate_0.13      labeling_0.3       knitr_1.22        
#> [28] curl_3.3           fansi_0.4.0        highr_0.8         
#> [31] broom_0.5.2        Rcpp_1.0.1         scales_1.0.0      
#> [34] backports_1.1.4    jsonlite_1.6       hms_0.4.2         
#> [37] digest_0.6.18      stringi_1.4.3      rlist_0.4.6.1     
#> [40] grid_3.6.0         cli_1.1.0          tools_3.6.0       
#> [43] magrittr_1.5       lazyeval_0.2.2     zeallot_0.1.0     
#> [46] crayon_1.3.4       pkgconfig_2.0.2    ellipsis_0.1.0    
#> [49] data.table_1.12.2  xml2_1.2.0         lubridate_1.7.4   
#> [52] assertthat_0.2.1   rmarkdown_1.12.6   httr_1.4.0        
#> [55] rstudioapi_0.10    R6_2.4.0           nlme_3.1-139      
#> [58] compiler_3.6.0
```

<div>

Icons made by
<a href="https://www.freepik.com/?__hstc=57440181.1504a979705d81fb44d4169a0ccdf2ae.1558036002089.1558036002089.1558036002089.1&__hssc=57440181.4.1558036002090&__hsfp=2902986854" title="Freepik">Freepik</a>
from
<a href="https://www.flaticon.com/"               title="Flaticon">www.flaticon.com</a>
is licensed by
<a href="http://creativecommons.org/licenses/by/3.0/"              title="Creative Commons BY 3.0" target="_blank">CC
3.0 BY</a>

</div>
