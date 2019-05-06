peRspective
================

Install package from GitHub:

``` r
devtools::install_github("favstats/peRspective")
```

``` r
library(peRspective)
```

## Example

``` r
key <- "xxx"

prsp_score("Hello whats going on? Please don't leave. I need to be free.", 
           key = key,
           score_model = peRspective::prsp_models)
```

    ## # A tibble: 1 x 16
    ##   TOXICITY SEVERE_TOXICITY IDENTITY_ATTACK INSULT PROFANITY
    ##      <dbl>           <dbl>           <dbl>  <dbl>     <dbl>
    ## 1   0.0828          0.0271          0.0754 0.0685    0.0475
    ## # ... with 11 more variables: SEXUALLY_EXPLICIT <dbl>, THREAT <dbl>,
    ## #   FLIRTATION <dbl>, ATTACK_ON_AUTHOR <dbl>, ATTACK_ON_COMMENTER <dbl>,
    ## #   INCOHERENT <dbl>, INFLAMMATORY <dbl>, LIKELY_TO_REJECT <dbl>,
    ## #   OBSCENE <dbl>, SPAM <dbl>, UNSUBSTANTIAL <dbl>
