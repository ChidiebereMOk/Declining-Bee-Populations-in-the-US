```SQL
bee_colonies(State_ANSI INT, County_ANSI INT, Ag_District_Code INT, Colonies_2002 INT, Colonies_2007 INT, Colonies_2012 INT, Colonies_2017 INT)
             PRIMARY KEY(State_ANSI, County_ANSI)
             FOREIGN KEY(State_ANSI, County_ANSI) REFERENCES Geo_codes(State_ANSI, County_ANSI)
             FOREIGN KEY(State_ANSI, Ag_District_Code) REFERENCES Ag_codes(State_ANSI, Ag_District_Code)
population(State_ANSI INT, County_ANSI INT, Rural_Urban_Code_2013 INT, Population_1990 TEXT, Population_2000 TEXT, Population_2010 TEXT, Population_2020 TEXT)
            PRIMARY KEY (State_ANSI, County_ANSI)
            FOREIGN KEY (State_ANSI, County_ANSI) REFERENCES geo_codes(State_ANSI, County_ANSI)

Ag_codes(State_ANSI INT, Ag_District_Code INT, District VARCHAR)
         PRIMARY KEY (State_ANSI, Ag_District_Code)

Geo_codes(Geo_level VARCHAR, State_ANSI INT, CountyANSI INT, State VARCHAR, Area_Name VARCHAR)
          PRIMARY KEY (State_ANSI, County_ANSI)
```
