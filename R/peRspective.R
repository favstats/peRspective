#' peRspective: Interface to the Perspective API
#'
#' Provides access to the Perspective API (\url{http://www.perspectiveapi.com/}). Perspective is an API that uses machine learning models to score the perceived impact a comment might have on a conversation.
#' `peRspective` provides access to the API using the R programming language.
#' For an excellent documentation of the Perspective API see [here](https://github.com/conversationai/perspectiveapi/blob/master/api_reference.md).
#'
#' @section Get API Key:
#'   1. Create a Google Cloud project in your [Google Cloud console](https://console.developers.google.com/)
#'
#'   2. Go to [Perspective API's overview page](https://console.developers.google.com/apis/api/commentanalyzer.googleapis.com/overview) and click **_Enable_**
#'   
#'   3. Go to the [API credentials page](https://console.developers.google.com/apis/credentials), just click **_Create credentials_**, and choose "API Key".
#' 
#' @section Suggested Usage of API Key:
#'   \pkg{peRspective} functions will read the API key from
#'   environment variable \code{perspective_api_key}. 
#'   You can specify it like this at the start of your script:
#'   
#'   \code{Sys.setenv(perspective_api_key = "**********")}
#'   
#'   To start R session with the
#'   initialized environment variable create an \code{.Renviron} file in your R home
#'   with a line like this:
#'   
#'   \code{perspective_api_key = "**********"}
#'
#'   To check where your R home is, try \code{normalizePath("~")}.
#'   
#' @section Quota and character length Limits:
#'   You can check your quota limits by going to [your google cloud project's Perspective API page](https://console.cloud.google.com/apis/api/commentanalyzer.googleapis.com/quotas), and check 
#'   your projects quota usage at 
#'   [the cloud console quota usage page](https://console.cloud.google.com/iam-admin/quotas).
#'
#'   The maximum text size per request is 3000 bytes.
#'   
#' @section Alpha models:
#' 
#' The following alpha models are **recommended** for use. They have been tested
#' across multiple domains and trained on hundreds of thousands of comments tagged
#' by thousands of human moderators. These are available in **English (en) and Spanish (es)**.
#' 
#' *   **TOXICITY**: rude, disrespectful, or unreasonable comment that is likely to
#' make people leave a discussion. This model is a
#' [Convolutional Neural Network](https://en.wikipedia.org/wiki/Convolutional_neural_network) (CNN)
#' trained with [word-vector](https://www.tensorflow.org/tutorials/word2vec)
#' inputs.
#' *   **SEVERE_TOXICITY**: This model uses the same deep-CNN algorithm as the
#' TOXICITY model, but is trained to recognise examples that were considered
#' to be 'very toxic' by crowdworkers. This makes it much less sensitive to
#' comments that include positive uses of curse-words for example. A labelled dataset
#' and details of the methodolgy can be found in the same [toxicity dataset](https://figshare.com/articles/Wikipedia_Talk_Labels_Toxicity/4563973) that is
#' available for the toxicity model.
#' 
#' @section Experimental models:
#' 
#' The following experimental models give more fine-grained classifications than
#' overall toxicity. They were trained on a relatively smaller amount of data
#' compared to the primary toxicity models above and have not been tested as
#' thoroughly.
#' 
#' *   **IDENTITY_ATTACK**: negative or hateful comments targeting someone because of their identity.
#' *   **INSULT**: insulting, inflammatory, or negative comment towards a person
#' or a group of people.
#' *   **PROFANITY**: swear words, curse words, or other obscene or profane
#' language.
#' *   **THREAT**: describes an intention to inflict pain, injury, or violence
#' against an individual or group.
#' *   **SEXUALLY_EXPLICIT**: contains references to sexual acts, body parts, or
#' other lewd content.
#' *   **FLIRTATION**: pickup lines, complimenting appearance, subtle sexual
#' innuendos, etc.
#' 
#' For more details on how these were trained, see the [Toxicity and sub-attribute annotation guidelines](https://github.com/conversationai/conversationai.github.io/blob/master/crowdsourcing_annotation_schemes/toxicity_with_subattributes.md).
#' 
#' @section New York Times moderation models:
#' 
#' The following experimental models were trained on New York Times data tagged by
#' their moderation team.
#' 
#' *   **ATTACK_ON_AUTHOR**: Attack on the author of an article or post.
#' *   **ATTACK_ON_COMMENTER**: Attack on fellow commenter.
#' *   **INCOHERENT**: Difficult to understand, nonsensical.
#' *   **INFLAMMATORY**: Intending to provoke or inflame.
#' *   **LIKELY_TO_REJECT**: Overall measure of the likelihood for the comment to
#' be rejected according to the NYT's moderation.
#' *   **OBSCENE**: Obscene or vulgar language such as cursing.
#' *   **SPAM**: Irrelevant and unsolicited commercial content.
#' *   **UNSUBSTANTIAL**: Trivial or short comments.
#'  
#' @md
#' @docType package
#' @name perspective-package
#' @aliases peRspective
NULL