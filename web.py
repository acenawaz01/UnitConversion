from flask import Flask, flash, redirect, render_template, request, session, abort
from flask_restful import request, Resource, Api
from random import randint

myapp = Flask(__name__)
myapi = Api(myapp)

class GetResult(Resource):
    def get(self):

        from_unit = request.args['from_unit']
        to_unit = request.args['to_unit']
        print(request.args['from_unit'])
        try:
           question_value = float(request.args['question_value'])
           entered_answer = float(request.args['entered_answer'])
        except:
           return "Incorrect"

        # Ignore case for inputs
        from_unit = from_unit.lower().strip()
        to_unit = to_unit.lower().strip()

        value_in_kelvin = 0
        correct_value = 0

        if from_unit in ['fahrenheit','kelvin','celsius','rankine'] and to_unit in ['fahrenheit','kelvin','celsius','rankine']:
        # Convert input unit to kelvin
           if from_unit == 'celsius':
              value_in_kelvin = question_value + 273.15
           if from_unit == 'fahrenheit':
              value_in_kelvin = ((question_value - 32)*5/9) + 273.15
           if from_unit == 'rankine':
              value_in_kelvin = ((input_vaule)*5)/9
           if from_unit == 'kelvin':
              value_in_kelvin = question_value

        # Convert kelvin to to_unit
           if to_unit == 'celsius':
              correct_value = value_in_kelvin - 273.15
           if to_unit == 'fahrenheit':
              correct_value = ((value_in_kelvin - 273.15)*9/5) + 32
           if to_unit == 'rankine':
              correct_value = value_in_kelvin * 1.8
           if to_unit == 'kelvin':
              correct_value = value_in_kelvin
        else:
           output = "invalid"
           return output
        if round(entered_answer,1) == round(correct_value,1):
           output = "correct"
        elif round(entered_answer,1) != round(correct_value,1):
           output = "Incorrect"
        else:
           output = "Incorrect"

        return output

myapi.add_resource(GetResult, '/result', endpoint='result')


if __name__ == "__main__":
    myapp.run(host='0.0.0.0', port=80)
