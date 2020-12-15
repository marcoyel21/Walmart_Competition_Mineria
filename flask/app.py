import flask
import pickle
import pandas as pd

# Use pickle to load in the pre-trained model
with open(f'model/model', 'rb') as f:
    model = pickle.load(f)

# Initialise the Flask app
app = flask.Flask(__name__, template_folder='templates')

# Set up the main route
@app.route('/', methods=['GET', 'POST'])
def main():
    if flask.request.method == 'GET':
        # Just render the initial form, to get input
        return(flask.render_template('main.html'))
    
    if flask.request.method == 'POST':
        # Extract the input


        A = flask.request.form['variedad']
        B = flask.request.form['scan_count']
        C = flask.request.form['regreso']
        D = flask.request.form['department_description_DSD GROCERY']
        E = flask.request.form['department_description_FINANCIAL SERVICES']
        F = flask.request.form['department_description_PERSONAL CARE']
        G = flask.request.form['department_description_PHARMACY OTC']
        H = flask.request.form['department_description_GROCERY DRY GOODS']
        I = flask.request.form['department_description_PRODUCE']
        J = flask.request.form['department_description_DAIRY']
        K = flask.request.form['department_description_SERVICE DELI']
        L = flask.request.form['department_description_IMPULSE MERCHANDISE']
        M = flask.request.form['department_description_MENSWEAR']
        N = flask.request.form['department_description_HOUSEHOLD CHEMICALS/SUPP']
        O = flask.request.form['department_description_PHARMACY RX']
        P = flask.request.form['department_description_INFANT CONSUMABLE HARDLINES']
        Q = flask.request.form['department_description_BEAUTY']
        R = flask.request.form['department_description_FROZEN FOODS']
        S = flask.request.form['department_description_HOUSEHOLD PAPER GOODS']
        T = flask.request.form['department_description_COMM BREAD']
        U = flask.request.form['department_description_CANDY, TOBACCO, COOKIES']
        V = flask.request.form['department_description_MEAT - FRESH & FROZEN'] 
        X = flask.request.form['department_description_LADIESWEAR']
        Y = flask.request.form['department_description_PETS AND SUPPLIES']
        Z = flask.request.form['weekday_Saturday']
        AA = flask.request.form['department_description_CELEBRATION']
        AB = flask.request.form['weekday_Friday']
        AC = flask.request.form['department_description_AUTOMOTIVE']
        AD = flask.request.form['department_description_SHOES']
        AE = flask.request.form['weekday_Sunday']
        AF = flask.request.form['department_description_LIQUOR,WINE,BEER']
        AG = flask.request.form['weekday_Monday']
        AH = flask.request.form['department_description_HOME MANAGEMENT']
        AI = flask.request.form['department_description_COOK AND DINE']
        AJ = flask.request.form['department_description_OFFICE SUPPLIES']
        AK = flask.request.form['department_description_TOYS']
        AL = flask.request.form['department_description_BAKERY']
        AM = flask.request.form['weekday_Thursday']
        AN = flask.request.form['weekday_Wednesday']
        AO = flask.request.form['weekday_Tuesday']
        AP = flask.request.form['department_description_SPORTING GOODS']
        AQ = flask.request.form['department_description_LAWN AND GARDEN']
        AR = flask.request.form['department_description_HARDWARE']
        AS = flask.request.form['department_description_ELECTRONICS']
        AT = flask.request.form['department_description_PRE PACKED DELI']
        AU = flask.request.form['department_description_HOME DECOR']
        AV = flask.request.form['department_description_WIRELESS']
        AW = flask.request.form['department_description_FABRICS AND CRAFTS']
        AX = flask.request.form['department_description_INFANT APPAREL']
        AY = flask.request.form['department_description_BATH AND SHOWER']

        # Make DataFrame for model
        input_variables = pd.DataFrame([[A, B,  C,  D,  E,  F,  G,  H,  I,  J,  K,  L,  M,  N,  O,  P,  Q,  R,  S,  T,  U,  V,  X,  Y,  Z,  AA, AB, AC, AD, AE, AF, AG, AH, AI, AJ, AK, AL, AM, AN, AO, AP, AQ, AR, AS, AT, AU, AV, AW, AX,AY]],
                                       columns=['variedad', 'scan_count', 'regreso',
                                                'department_description_DSD GROCERY',
                                                'department_description_FINANCIAL SERVICES',
                                                'department_description_PERSONAL CARE',
                                                'department_description_PHARMACY OTC',
                                                'department_description_GROCERY DRY GOODS',
                                                'department_description_PRODUCE', 'department_description_DAIRY',
                                                'department_description_SERVICE DELI',
                                                'department_description_IMPULSE MERCHANDISE',
                                                'department_description_MENSWEAR',
                                                'department_description_HOUSEHOLD CHEMICALS/SUPP',
                                                'department_description_PHARMACY RX',
                                                'department_description_INFANT CONSUMABLE HARDLINES',
                                                'department_description_BEAUTY', 'department_description_FROZEN FOODS',
                                                'department_description_HOUSEHOLD PAPER GOODS',
                                                'department_description_COMM BREAD',
                                                'department_description_CANDY, TOBACCO, COOKIES',
                                                'department_description_MEAT - FRESH & FROZEN',
                                                'department_description_LADIESWEAR',
                                                'department_description_PETS AND SUPPLIES', 'weekday_Saturday',
                                                'department_description_CELEBRATION', 'weekday_Friday',
                                                'department_description_AUTOMOTIVE', 'department_description_SHOES',
                                                'weekday_Sunday', 'department_description_LIQUOR,WINE,BEER',
                                                'weekday_Monday', 'department_description_HOME MANAGEMENT',
                                                'department_description_COOK AND DINE',
                                                'department_description_OFFICE SUPPLIES', 'department_description_TOYS',
                                                'department_description_BAKERY', 'weekday_Thursday',
                                                'weekday_Wednesday', 'weekday_Tuesday',
                                                'department_description_SPORTING GOODS',
                                                'department_description_LAWN AND GARDEN',
                                                'department_description_HARDWARE', 'department_description_ELECTRONICS',
                                                'department_description_PRE PACKED DELI',
                                                'department_description_HOME DECOR', 'department_description_WIRELESS',
                                                'department_description_FABRICS AND CRAFTS',
                                                'department_description_INFANT APPAREL',
                                                'department_description_BATH AND SHOWER'],
                                       dtype=float,
                                       index=['input'])

        # Get the model's prediction
        prediction = model.predict(input_variables)[0]
    
        # Render the form again, but add in the prediction and remind user
        # of the values they input before
        return flask.render_template('main.html',
                                     original_input={'variedad':A,
                                                     'scan_count':B,
                                                     'regreso':C,
                                                     'department_description_DSD GROCERY':D,
                                                     'department_description_FINANCIAL SERVICES':E,
                                                     'department_description_PERSONAL CARE':F,
                                                     'department_description_PHARMACY OTC':G,
                                                     'department_description_GROCERY DRY GOODS':H,
                                                     'department_description_PRODUCE':I,
                                                     'department_description_DAIRY':J,
                                                     'department_description_SERVICE DELI':K,
                                                     'department_description_IMPULSE MERCHANDISE':L,
                                                     'department_description_MENSWEAR':M,
                                                     'department_description_HOUSEHOLD CHEMICALS/SUPP':N,
                                                     'department_description_PHARMACY RX':O,
                                                     'department_description_INFANT CONSUMABLE HARDLINES':P,
                                                     'department_description_BEAUTY':Q,
                                                     'department_description_FROZEN FOODS':R,
                                                     'department_description_HOUSEHOLD PAPER GOODS':S,
                                                     'department_description_COMM BREAD':T,
                                                     'department_description_CANDY, TOBACCO, COOKIES':U,
                                                     'department_description_MEAT - FRESH & FROZEN':V,
                                                     'department_description_LADIESWEAR':X,
                                                     'department_description_PETS AND SUPPLIES':Y,
                                                     'weekday_Saturday':Z,
                                                     'department_description_CELEBRATION':AA,
                                                     'weekday_Friday':AB,
                                                     'department_description_AUTOMOTIVE':AC,
                                                     'department_description_SHOES':AD,
                                                     'weekday_Sunday':AE,
                                                     'department_description_LIQUOR,WINE,BEER':AF,
                                                     'weekday_Monday':AG,
                                                     'department_description_HOME MANAGEMENT':AH,
                                                     'department_description_COOK AND DINE':AI,
                                                     'department_description_OFFICE SUPPLIES':AJ,
                                                     'department_description_TOYS':AK,
                                                     'department_description_BAKERY':AL,
                                                     'weekday_Thursday':AM,
                                                     'weekday_Wednesday':AN,
                                                     'weekday_Tuesday':AO,
                                                     'department_description_SPORTING GOODS':AP,
                                                     'department_description_LAWN AND GARDEN':AQ,
                                                     'department_description_HARDWARE':AR,
                                                     'department_description_ELECTRONICS':AS,
                                                     'department_description_PRE PACKED DELI':AT,
                                                     'department_description_HOME DECOR':AU,
                                                     'department_description_WIRELESS':AV,
                                                     'department_description_FABRICS AND CRAFTS':AW,
                                                     'department_description_INFANT APPAREL':AX,
                                                     'department_description_BATH AND SHOWER':AY},
                                     result=prediction,
                                     )

if __name__ == '__main__':
    app.run()