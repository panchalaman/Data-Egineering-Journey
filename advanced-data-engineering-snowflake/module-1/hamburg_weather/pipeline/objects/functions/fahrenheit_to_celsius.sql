CREATE OR ALTER FUNCTION {{env}}_tasty_bytes.analytics.fahrenheit_to_celsius(temp_f NUMBER(35,4))
  RETURNS NUMBER(35,4)
  AS
  $$
    (temp_f - 32) * (5/9)
  $$
;