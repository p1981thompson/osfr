#' Personalised welcome
#'
#' @return Welcome message of logged in user, if any
#' @export

welcome <- function(...)
{
  if (Sys.getenv("OSF_PAT") == "")
  {
    login()
    call <- httr::GET(url = construct_link(...))
  }
  else
  {
    call <- httr::GET(url = construct_link(...),
                      httr::add_headers(Authorization = sprintf("Bearer %s", login())))
  }

  res <- process_json(call)

  if (is.null(res$meta$current_user))
  {
    warning("Currently not logged in\n")
  }

  if (!is.null(res$meta$current_user))
  {
    cat(sprintf("Welcome %s", res$meta$current_user$data$attributes$full_name))
  }
}

#' Login function; interactive without arguments
#'
#' @param pat Personal Access Token (PAT) for fast login. If no pat is given, function queries for it.
#'
#' @return Personal access token from global environment.
#' @export

login <- function(pat = NULL){
  if (!is.null(pat))
  {
    Sys.setenv(OSF_PAT = pat)
  } else
  {
    if (Sys.getenv("OSF_PAT") == ""){
      input <- readline(prompt = "Visit https://osf.io/settings/tokens/
                        and create a Personal access token: ")

      Sys.setenv(OSF_PAT = input)

      if (file.exists(paste0(normalizePath('~/'), '.Renviron')))
      {
        write(sprintf('OSF_PAT=%s', input),
              paste0(normalizePath('~/'), '/.Renviron'),
              append = TRUE)
      } else
      {
        write(sprintf('OSF_PAT=%s', input),
              paste0(normalizePath('~/'), '/.Renviron'),
              append = FALSE)
      }
    }
  }

  return(Sys.getenv("OSF_PAT"))
}

#' Logout function
#'
#' @return Boolean succes of logout
#' @export

logout <- function(...)
{
  if (Sys.getenv("OSF_PAT") == "")
  {
    cat("Not logged in.")

    return(FALSE)
  } else
  {
    Sys.setenv(OSF_PAT = "")

    return(TRUE)
  }
}

#' Cleaning up PAT file
#'
#' This function ensures that when having used a device, the access token is deleted.
#' This is important to ensure that there is no remainder lying around allowing illicit
#' access to your account.
#'
#' @return Boolean of cleanup success.
#' @export

cleanup <- function()
{
  fn <- normalizePath('~/.Renviron')
  if (file.exists(fn)) file.remove(fn)
}
