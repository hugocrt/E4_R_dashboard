"""
    Module which provide the whole process from webscraping to dashboarding
"""
from data_processor.data_processor import DataFrameHolder
from web_scraper.web_scraper import FirefoxScraperHolder

# "URL" required to collect the data
TARGET_URL = ('https://data.economie.gouv.fr/explore/dataset/prix-des-'
              'carburants-en-france-flux-instantane-v2/')
# "aria_label" is used to specify the area for retrieving the link.
CSV_ARIA_LABEL = 'Dataset export (CSV)'
# metadata is used to specify the area for retrieving the date
UPDATED_DATA_DATE_NG_IF = 'ctx.dataset.metas.data_processed'

# Retrieves datas
firefox_scraper = FirefoxScraperHolder(TARGET_URL)
firefox_scraper.remove_cwf_existing_csvs()
firefox_scraper.perform_scraping(CSV_ARIA_LABEL, UPDATED_DATA_DATE_NG_IF)

with open("date.txt", "w") as file:
    file.write(
      f"Date de la dernière modification : {firefox_scraper.updated_data_date}"
      f"\n"
    )

print(firefox_scraper.updated_data_date)

# Data processing
df_holder = DataFrameHolder(firefox_scraper.csv_id)
df_holder.process_data()
df_holder.save_dataframe()
