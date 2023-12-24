library(purrr)
library(dplyr)
library(tidyr)

data <- readLines("input.txt")

process_line <- function(x) {
    if (x == "noop") {
        return(list(
            cycles = 1,
            value = 0
        ))
    }
    if (grepl("addx", x)) {
        return(data.frame(
            cycles = c(1, 1),
            value = c(NA, as.numeric(strsplit(x, " ")[[1]][2]))
        ))
    }
}

cycles <- map_dfr(data, process_line)

cumulative_values <- cycles %>%
    mutate(value = coalesce(value, 0)) %>%
    mutate(
        cycle = cumsum(cycles),
        after = cumsum(value) + 1,
        during = lag(after, default = 1)
    ) %>%
    arrange(cycle) %>%
    fill(after, during)

# Get value of 20, then every 40th value after that
signal_indexes <- c(20, seq(60, max(cumulative_values$cycle), 40))
signal_strength <- cumulative_values %>%
    filter(cycle %in% signal_indexes) %>%
    mutate(strength = cycle * during)

total_signal <- sum(signal_strength$strength)

print(total_signal)


# Part 2
pmap(list(cumulative_cycles$cycle, cumulative_cycles$during, cumulative_cycles$after), function(cycle, during, after) {
    position < cycle - 1
    sprite_positions <- c(during - 1, during, during + 1)
    if (position %in% sprite_positions) {
        return("#")
    }
    return(".")
})