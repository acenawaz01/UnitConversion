from flask import Flask, flash, redirect, render_template, request, session, abort
from random import randint

myapp = Flask(__name__)

@myapp.route("/")
def hello():
    return render_template(
        'app.html', **locals())

# Logic for temperature conversion
@myapp.route('/send', methods=['POST'])
def send():
    if request.method == 'POST':
        input_unit = request.form['input_unit']
        output_unit = request.form['output_unit']

        try:
           input_value = float(request.form['input_value'])
           student_response = float(request.form['student_response'])
        except:
           return render_template('app.html', result="incorrect")

        # Ignore case for inputs
        input_unit_ic = input_unit.lower().strip()
        output_unit_ic = output_unit.lower().strip()

        mid_value = 0
        output_value = 0

        if input_unit_ic in ['fahrenheit','kelvin','celsius','rankine'] and output_unit_ic in ['fahrenheit','kelvin','celsius','rankine']:
        # Convert input unit to kelvin
           if input_unit_ic == 'celsius':
              mid_value = input_value + 273.15
           elif input_unit_ic == 'fahrenheit':
              mid_value = ((input_value - 32)*5/9) + 273.15
           elif input_unit_ic == 'rankine':
              mid_value = ((input_vaule)*5)/9
           elif input_unit_ic == 'kelvin':
              mid_value = input_value

        # Convert kelvin to output_unit
           if output_unit_ic == 'celsius':
              output_value = mid_value - 273.15
           elif output_unit_ic == 'fahrenheit':
              output_value = ((mid_value - 273.15)*9/5) + 32
           elif output_unit_ic == 'rankine':
              output_value = mid_value * 1.8
           elif output_unit_ic == 'kelvin':
              output_value = mid_value
        else:
           output = "invalid"
        if round(student_response,1) == round(output_value,1):
           output = "correct"
        elif round(student_response,1) != round(output_value,1):
           output = "incorrect"
        else:
           output = "incorrect"

        return render_template('app.html', result=output)


if __name__ == "__main__":
    myapp.run(host='0.0.0.0', port=80)
