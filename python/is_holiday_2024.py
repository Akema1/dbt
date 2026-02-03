#Code to identify US holidays
import holidays
import pandas

def model(dbt, session)

        dbt.config.(
                materialization="table",
                packages= ["pandas","holidays"]
        )

        us_holidays = holidays.US()

        df = dbt.refs('date_spine').to_pandas()
        df['IS_HOLIDAY'] = df['DATE_DAY'].apply(lambda date: date in us_holidays)

        return df