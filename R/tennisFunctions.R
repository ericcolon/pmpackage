
usethis::use_package('readxl')
usethis::use_package('janitor')
usethis::use_package('purrr')
usethis::use_package('tibble')
usethis::use_package('stringr')



#' Fetch tennis results from www.tennis-data.co.uk
#'
#' @param myyear
#' @param competition 'WTA' by default
#'
#' @return
#' @export
#'
#' @examples
#' #'
#' @importFrom magrittr "%>%"
pm_tennis_fetchDataset <- function(myyear,
                                         competition = 'WTA'){

  if (competition == 'WTA'){
    availableFiles <- list(
      'y2007' = 'http://www.tennis-data.co.uk/2007w/2007.zip',
      'y2008' = 'http://www.tennis-data.co.uk/2008w/2008.zip',
      'y2009' = 'http://www.tennis-data.co.uk/2009w/2009.zip',
      'y2010' = 'http://www.tennis-data.co.uk/2009w/2009.zip',
      'y2011' = 'http://www.tennis-data.co.uk/2011w/2011.zip',
      'y2012' = 'http://www.tennis-data.co.uk/2012w/2012.zip',
      'y2013' = 'http://www.tennis-data.co.uk/2013w/2013.zip',
      'y2014' = 'http://www.tennis-data.co.uk/2014w/2014.zip',
      'y2015' = 'http://www.tennis-data.co.uk/2015w/2015.zip',
      'y2016' = 'http://www.tennis-data.co.uk/2016w/2016.zip',
      'y2017' = 'http://www.tennis-data.co.uk/2017w/2017.zip',
      'y2018' = 'http://www.tennis-data.co.uk/2018w/2018.zip',
      'y2019' = 'http://www.tennis-data.co.uk/2019w/2019.zip',
      'y2020' = 'http://www.tennis-data.co.uk/2020w/2020.zip'
    )
  } else if (competition == 'ATP'){
    availableFiles <- list(
      'y2001' = 'http://www.tennis-data.co.uk/2001/2001.zip',
      'y2002' = 'http://www.tennis-data.co.uk/2002/2002.zip',
      'y2003' = 'http://www.tennis-data.co.uk/2003/2003.zip',
      'y2004' = 'http://www.tennis-data.co.uk/2004/2004.zip',
      'y2005' = 'http://www.tennis-data.co.uk/2005/2005.zip',
      'y2006' = 'http://www.tennis-data.co.uk/2006/2006.zip',
      'y2007' = 'http://www.tennis-data.co.uk/2007/2007.zip',
      'y2008' = 'http://www.tennis-data.co.uk/2008/2008.zip',
      'y2009' = 'http://www.tennis-data.co.uk/2009/2009.zip',
      'y2010' = 'http://www.tennis-data.co.uk/2010/2010.zip',
      'y2011' = 'http://www.tennis-data.co.uk/2011/2011.zip',
      'y2012' = 'http://www.tennis-data.co.uk/2012/2012.zip',
      'y2013' = 'http://www.tennis-data.co.uk/2013/2013.zip',
      'y2014' = 'http://www.tennis-data.co.uk/2014/2014.zip',
      'y2015' = 'http://www.tennis-data.co.uk/2015/2015.zip',
      'y2016' = 'http://www.tennis-data.co.uk/2016/2016.zip',
      'y2017' = 'http://www.tennis-data.co.uk/2017/2017.zip',
      'y2018' = 'http://www.tennis-data.co.uk/2018/2018.zip',
      'y2019' = 'http://www.tennis-data.co.uk/2019/2019.zip',
      'y2020' = 'http://www.tennis-data.co.uk/2020/2020.zip'
    )
  }

  # remove some extra variables
  extraVars = c(
    'B365W',
    'B365L',
    'B&WW',
    'B&WL',
    'CBW',
    'CBL',
    'EXW',
    'EXL',
    'LBW',
    'LBL',
    'GBW',
    'GBL',
    'IWW',
    'IWL',
    'PSW',
    'PSL',
    'SBW',
    'SBL',
    'SJW',
    'SJL',
    'UBW',
    'UBL',

    'MaxW',
    'MaxL',
    'AvgW',
    'AvgL',
    'W1',
    'W2',
    'W3',
    'W4',
    'W5',
    'L1',
    'L2',
    'L3',
    'L4',
    'L5',
    'wta'
  )

  td = tempdir()
  # create the placeholder file
  tf = tempfile(tmpdir=td, fileext=".zip")

  myfilename <- unlist(availableFiles[paste0("y",myyear)])
  download.file(myfilename,tf)

  fname = unzip(tf, list=TRUE)$Name[1]
  # unzip the file to the temporary directory
  unzip(tf, files=fname, exdir=td, overwrite=TRUE)
  # fpath is the full path to the extracted file
  fpath = file.path(td, fname)

  if (competition == 'WTA'){
    dfMatch <- readxl::read_excel(fpath, guess_max = Inf) %>%
      janitor::clean_names() %>%
      tibble::as.tibble() %>%
      dplyr::select(-one_of(tolower(extraVars))) %>%
      dplyr::rename(match_date = date,
                    series = tier,
                    match_location = location) %>%
      dplyr::filter(!is.na(match_date)) %>%
      dplyr::mutate(w_rank = as.integer(w_rank),
                    w_pts = as.integer(w_pts),
                    l_rank = as.integer(l_rank),
                    l_pts = as.integer(l_pts),
                    wsets = as.integer(wsets),
                    lsets = as.integer(lsets),
                    tournament = stringr::str_replace_all(tournament,"[^a-zA-Z\\s]", " "),
                    winner = trimws(winner),
                    loser = trimws(loser))
  } else if (competition == 'ATP'){
    dfMatch <- readxl::read_excel(fpath, guess_max = Inf) %>%
      janitor::clean_names() %>%
      tibble::as.tibble() %>%
      dplyr::select(-one_of(tolower(extraVars))) %>%
      dplyr::rename(match_date = date,
                    match_location = location) %>%
      dplyr::filter(!is.na(match_date)) %>%
      dplyr::mutate(w_rank = as.integer(w_rank),
                    w_pts = as.integer(w_pts),
                    l_rank = as.integer(l_rank),
                    l_pts = as.integer(l_pts),
                    wsets = as.integer(wsets),
                    lsets = as.integer(lsets),
                    tournament = stringr::str_replace_all(tournament,"[^a-zA-Z\\s]", " "),
                    winner = trimws(winner),
                    loser = trimws(loser))

  }

  #fix match_date
  dfMatch$roundChar = substr(dfMatch$round,1,1)
  dfMatch$roundNum = ifelse(dfMatch$roundChar == 'T',1,
                         ifelse(dfMatch$roundChar == 'S',2,
                                ifelse(dfMatch$roundChar == 'Q',4,
                                       ifelse(dfMatch$roundChar == '4',8,
                                              ifelse(dfMatch$roundChar == '3',16,
                                                     ifelse(dfMatch$roundChar == '2',32,
                                                            ifelse(dfMatch$roundChar == '1',64,
                                                                   ifelse(dfMatch$roundChar == 'R',128,
                                                                          256))))))))
  dfMatch$match_date = dfMatch$match_date + 1000 * 1/dfMatch$roundNum
  # Now match date are no longer equal provided the roundNum is different... :)

  #Still some duplicates
  dfMatch <- dplyr::distinct(dfMatch)


  dfMatch
}


#' Get all available historical data
#'
#' @param competition
#'
#' @return
#' @export
#'
#' @importFrom magrittr "%>%"
#' @examples
pm_tennis_fetchAllDatasets <- function(competition = 'WTA'){

  myyears <- seq(from=2018,to=2020,by=1)

  allTheData <- myyears %>%
    purrr::map(~ pm_tennis_fetchDataset(., competition = competition)) %>%
    purrr::reduce(bind_rows) %>%
    dplyr::distinct(winner,loser,match_date,tournament,round,.keep_all=TRUE)

  allTheData
}




#' Convert raw data into an Elo-friendly format
#'
#' @param my_raw_data
#'
#' @return
#' @export
#'
#' @importFrom magrittr "%>%"
#' @examples
pm_tennis_eloify_dataset <- function(my_raw_data){
  mydata <- my_raw_data %>%
    dplyr::mutate(sampleSide = rbinom(nrow(my_raw_data),1,0.5))

  mywinners <- mydata %>% dplyr::filter(sampleSide == 1)
  mylosers <- mydata %>% dplyr::filter(sampleSide == 0)

  mywinners <- mywinners %>%
    dplyr::mutate(actualResult = 1)
  names(mywinners)[names(mywinners) == 'winner'] <- 'player_name'
  names(mywinners)[names(mywinners) == 'loser'] <- 'opponent_name'
  colnums = grep('^w',x=names(mywinners),ignore.case = TRUE)
  names(mywinners)[colnums] = gsub(pattern = 'w',replacement = 'player',x=names(mywinners)[colnums],ignore.case = TRUE)
  colnums = grep('^l',x=names(mywinners),ignore.case = TRUE)
  names(mywinners)[colnums] = gsub(pattern = 'l',replacement = 'opponent',x=names(mywinners)[colnums],ignore.case = TRUE)


  mylosers <- mylosers %>%
    dplyr::mutate(actualResult = 0)
  names(mylosers)[names(mylosers) == 'winner'] <- 'opponent_name'
  names(mylosers)[names(mylosers) == 'loser'] <- 'player_name'
  colnums = grep('^l',x=names(mylosers),ignore.case = TRUE)
  names(mylosers)[colnums] = gsub(pattern = 'l',replacement = 'player',x=names(mylosers)[colnums],ignore.case = TRUE)
  colnums = grep('^w',x=names(mylosers),ignore.case = TRUE)
  names(mylosers)[colnums] = gsub(pattern = 'w',replacement = 'opponent',x=names(mylosers)[colnums],ignore.case = TRUE)

  bind_rows(mywinners,
            mylosers) %>%
    dplyr::arrange(match_date)
}
