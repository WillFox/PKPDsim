#' Only core function of the simulation function, always just returns observations.
#' Mostly useful for estimations / optimal design. Has no checks (for speed)!
#'
#' @param sim_object list with design and simulation parameters
#' @param ode ode
#' @param duplicate_t_obs allow duplicate t_obs in output? E.g. for optimal design calculations when t_obs = c(0,1,2,2,3). Default is FALSE.
#' @export
sim_core <- function(
  sim_object = NULL,
  ode,
  duplicate_t_obs = FALSE,
  t_init = 0) {
  tmp <- ode(A = sim_object$A_init,
             design = sim_object$design,
             par = sim_object$p,
             iov_bins = sim_object$iov_bins,
             step_size = sim_object$int_step_size)
  out <- data.frame(t = tmp$time, y = tmp$obs)
  if(duplicate_t_obs) {
    out <- out[match(sim_object$t_obs, out$t),] # use match to ensure that duplicates in t_obs is possible
  } else {
    out <- out[!duplicated(out$t) & out$t %in% sim_object$t_obs,]
  }
  out$t <- out$t - t_init
  return(out)
}
