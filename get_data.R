library(rvest)

# state population centers since 1880 census
download.file("http://www2.census.gov/geo/docs/reference/cenpop2010/nat_cop_1880_2010.txt", 'data/state_pop_centers.csv')

state_capital_url <- 'https://www.jetpunk.com/data/countries/united-states/state-capitals-list'
xml <- read_html(state_capital_url)
node <- html_node(x = xml, xpath = '//*[@id="data-table"]')
q <- html_table(node)
write.table(q, file = 'data/state_capitals.csv', quote = FALSE, sep = ',', row.names = FALSE)
