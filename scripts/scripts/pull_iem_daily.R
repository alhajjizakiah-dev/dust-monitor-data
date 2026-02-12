
suppressPackageStartupMessages({
  library(httr)
  library(lubridate)
})

# اسحب "أمس" UTC لضمان اكتمال اليوم
day_utc <- as.Date(Sys.time(), tz = "UTC") - 1

year1 <- year(day_utc); month1 <- month(day_utc); day1 <- day(day_utc)
year2 <- year(day_utc); month2 <- month(day_utc); day2 <- day(day_utc)

base <- "https://mesonet.agron.iastate.edu/cgi-bin/request/asos.py"

q <- list(
  network = "SA__ASOS",
  data = "metar",          # أخف من all
  year1 = year1, month1 = month1, day1 = day1,
  year2 = year2, month2 = month2, day2 = day2,
  tz = "Etc/UTC",
  format = "onlycomma",
  latlon = "no",
  elev = "no",
  missing = "M",
  trace = "T",
  direct = "no",
  report_type = c("3","4")
)

resp <- GET(base, query = q, timeout(120))
stop_for_status(resp)

txt <- content(resp, as = "text", encoding = "UTF-8")

if (!grepl("^station,", txt)) {
  writeLines(substr(txt, 1, 800))
  stop("Response not CSV header. Check query.")
}

dir.create("data", showWarnings = FALSE, recursive = TRUE)

dated <- sprintf("data/metar_SA__ASOS_%s.csv", format(day_utc, "%Y-%m-%d"))
writeLines(txt, dated, useBytes = TRUE)

# ملف ثابت لربط Skywork (الأهم)
file.copy(dated, "data/metar_SA__ASOS_latest.csv", overwrite = TRUE)

message("Saved: ", dated)
message("Updated: data/metar_SA__ASOS_latest.csv")
