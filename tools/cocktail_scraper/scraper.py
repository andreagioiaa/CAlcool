import urllib.request
import urllib.parse
import json
import re
import os
import ssl

# Mappa degli ingredienti comuni e il loro ABV standard (%)
INGREDIENT_ABV = {
    # Distillati & Liquori Forti (~40%)
    'gin': 40.0,
    'vodka': 40.0,
    'rum': 40.0,
    'light rum': 40.0,
    'dark rum': 40.0,
    'white rum': 40.0,
    'spiced rum': 37.5,
    'tequila': 40.0,
    'whiskey': 40.0,
    'whisky': 40.0,
    'bourbon': 40.0,
    'scotch': 40.0,
    'brandy': 40.0,
    'cognac': 40.0,
    'triple sec': 40.0,
    'cointreau': 40.0,
    'grand marnier': 40.0,
    'bacardi': 40.0,
    'cachaça': 40.0,
    'cachaca': 40.0,
    
    # Amari & Liquori Medi
    'campari': 25.0,
    'aperol': 11.0,
    'kahlua': 20.0,
    'baileys': 17.0,
    'baileys irish cream': 17.0,
    'irish cream': 17.0,
    'amaretto': 28.0,
    'disaronno': 28.0,
    'malibu': 21.0,
    'passoa': 17.0,
    'southern comfort': 35.0,
    'limoncello': 30.0,
    'sambuca': 38.0,
    'galliano': 30.0,
    'blue curacao': 20.0,
    'peach schnapps': 15.0,
    
    # Vini Fortificati & Vermouth
    'vermouth': 15.0,
    'sweet vermouth': 15.0,
    'dry vermouth': 15.0,
    'rosso vermouth': 15.0,
    'sherry': 17.0,
    'port': 20.0,
    
    # Vini & Bollicine
    'prosecco': 11.5,
    'champagne': 12.0,
    'red wine': 12.5,
    'white wine': 12.0,
    
    # Birre
    'beer': 5.0,
    'guinness': 4.2,
    
    # Analcolici (0%)
    'tonic water': 0.0,
    'soda water': 0.0,
    'club soda': 0.0,
    'coca-cola': 0.0,
    'coke': 0.0,
    'ginger beer': 0.0,
    'ginger ale': 0.0,
    'lime juice': 0.0,
    'lemon juice': 0.0,
    'orange juice': 0.0,
    'pineapple juice': 0.0,
    'cranberry juice': 0.0,
    'sugar syrup': 0.0,
    'simple syrup': 0.0,
    'grenadine': 0.0,
    'water': 0.0,
    'milk': 0.0,
    'cream': 0.0,
    'coconut cream': 0.0,
    'tomato juice': 0.0,
}

# Lista di cocktail popolari da cercare
POPULAR_COCKTAILS = [
    "Gin Tonic",
    "Negroni",
    "Mojito",
    "Margarita",
    "Martini",
    "Aperol Spritz",
    "Cuba Libre",
    "Moscow Mule",
    "Whiskey Sour",
    "Daiquiri",
    "Manhattan",
    "Old Fashioned",
    "Pina Colada",
    "Bloody Mary",
    "Americano",
    "Caipirinha",
    "Irish Coffee",
    "Long Island Iced Tea",
    "Tequila Sunrise",
    "Espresso Martini",
    "Cosmopolitan",
    "White Russian",
    "Black Russian",
    "Sex on the Beach"
]

def parse_fraction(s):
    """Converte frazioni stringa (es: '1 1/2' o '1/2') in float."""
    s = s.strip()
    if not s:
        return 0.0
    
    # Cerca frazione mista: "1 1/2"
    mixed_match = re.match(r'^(\d+)\s+(\d+)/(\d+)$', s)
    if mixed_match:
        return float(mixed_match.group(1)) + float(mixed_match.group(2)) / float(mixed_match.group(3))
        
    # Cerca frazione semplice: "1/2"
    frac_match = re.match(r'^(\d+)/(\d+)$', s)
    if frac_match:
        return float(frac_match.group(1)) / float(frac_match.group(2))
        
    # Cerca decimale o intero
    try:
        return float(s)
    except ValueError:
        return 0.0

def estimate_volume_ml(measure_str, ingredient_name):
    """Analizza la stringa della misura di TheCocktailDB e restituisce i ml stimati."""
    i_clean = ingredient_name.lower().strip()
    
    if not measure_str or measure_str.lower().strip() == 'none' or measure_str.strip() == '':
        # Se la misura è assente ma l'ingrediente è un noto analcolico filler (tonica, soda, cola, ginger)
        if any(x in i_clean for x in ['tonic', 'soda', 'coke', 'cola', 'ginger', 'sprite', 'water']):
            return 120.0
        # Succhi analcolici
        if 'juice' in i_clean:
            return 90.0
        # Creme o latte
        if any(x in i_clean for x in ['cream', 'milk', 'yoghurt']):
            return 30.0
        # Sciroppi
        if any(x in i_clean for x in ['syrup', 'grenadine', 'sugar']):
            return 15.0
        # Frutta (lime, limone)
        if any(x in i_clean for x in ['lime', 'lemon', 'orange']):
            return 15.0
        return 0.0
        
    m_clean = measure_str.lower().strip()
    
    # Caso speciale: "top up", "fill", "top"
    if "top" in m_clean or "fill" in m_clean:
        # Se è un filler analcolico (soda, cola, tonica), assumiamo 100-120ml
        if any(x in i_clean for x in ['tonic', 'soda', 'coke', 'cola', 'ginger', 'juice', 'sprite']):
            return 120.0
        return 30.0

    # Caso speciale: "juice of 1/2"
    if "juice of" in m_clean:
        return 20.0 # circa 20ml per mezzo limone/lime

    # Trova i numeri (interi, decimali o frazioni)
    # Cerca pattern tipo "1 1/2", "0.5", "2/3", "3"
    num_match = re.search(r'(\d+\s+\d+/\d+|\d+/\d+|\d+\.\d+|\d+)', m_clean)
    if not num_match:
        # Se non c'è un numero ma c'è scritto "dash" o "splash"
        if "dash" in m_clean or "splash" in m_clean:
            return 1.0
        return 0.0
        
    val = parse_fraction(num_match.group(1))
    
    # Determina l'unità di misura
    if "oz" in m_clean or "ounce" in m_clean:
        return val * 30.0 # 1 oz = ~30ml
    elif "cl" in m_clean:
        return val * 10.0 # 1 cl = 10ml
    elif "ml" in m_clean:
        return val * 1.0
    elif "dash" in m_clean or "dashes" in m_clean:
        return val * 1.0 # 1 dash = ~1ml
    elif "shot" in m_clean or "shots" in m_clean:
        return val * 45.0 # 1 shot standard = 45ml
    elif "tsp" in m_clean or "tea spoon" in m_clean:
        return val * 5.0 # 1 cucchiaino = 5ml
    elif "tblsp" in m_clean or "tbsp" in m_clean or "tablespoon" in m_clean:
        return val * 15.0 # 1 cucchiaio = 15ml
    elif "part" in m_clean or "parts" in m_clean:
        # Se parla di parti, proviamo a stimare (es: 1 part = 30ml)
        return val * 30.0
    else:
        # Se non c'è unità ma il numero è piccolo (es: 1, 1.5, 2), probabilmente sono oz o cl o parti
        if val <= 5.0:
            # Se l'ingrediente è un distillato/liquore, ipotizziamo oz (30ml)
            # Se è prosecco o soda, potrebbe essere di più, ma restiamo conservativi su oz (30ml)
            return val * 30.0
        else:
            # Se il valore è grande (es: 50, 100), probabilmente sono ml
            return val

def get_ingredient_abv(ingredient_name):
    """Restituisce l'ABV stimato per l'ingrediente."""
    i_clean = ingredient_name.lower().strip()
    
    # Cerca corrispondenza esatta nella mappa
    if i_clean in INGREDIENT_ABV:
        return INGREDIENT_ABV[i_clean]
        
    # Altrimenti cerca corrispondenza parziale
    for key, abv in INGREDIENT_ABV.items():
        if key in i_clean:
            return abv
            
    # Se non trovato ed è classificato come alcolico generico
    if any(x in i_clean for x in ['liquor', 'liqueur', 'spirit', 'alcohol']):
        return 20.0 # Assunzione conservativa per liquore generico
        
    # Default a 0% se sembra analcolico (succhi, sciroppi, frutta)
    return 0.0

def fetch_cocktail_data(cocktail_name):
    """Interroga l'API di TheCocktailDB e calcola Volume e ABV."""
    query = urllib.parse.quote(cocktail_name)
    url = f"https://www.thecocktaildb.com/api/json/v1/1/search.php?s={query}"
    
    try:
        req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
        context = ssl._create_unverified_context()
        with urllib.request.urlopen(req, context=context) as response:
            data = json.loads(response.read().decode())
            
        if not data or not data.get('drinks'):
            print(f"[Warning] Cocktail '{cocktail_name}' non trovato sull'API.")
            return None
            
        # Prendi il primo risultato
        drink_data = data['drinks'][0]
        
        name = drink_data['strDrink']
        ingredients = []
        total_vol = 0.0
        total_alcohol_vol = 0.0
        
        # Ci sono fino a 15 ingredienti nelle risposte dell'API
        for i in range(1, 16):
            ing_name = drink_data.get(f'strIngredient{i}')
            measure = drink_data.get(f'strMeasure{i}')
            
            if not ing_name:
                break
                
            vol = estimate_volume_ml(measure, ing_name)
            abv = get_ingredient_abv(ing_name)
            
            if vol > 0:
                ingredients.append({
                    "ingredient": ing_name,
                    "measure": measure.strip() if measure else "",
                    "volumeMl": vol,
                    "abv": abv
                })
                total_vol += vol
                total_alcohol_vol += (vol * (abv / 100.0))
            else:
                print(f"     [Debug] Ignorato ingrediente '{ing_name}' con misura '{measure}'")
                
        if total_vol == 0:
            print(f"[Warning] Impossibile calcolare il volume per '{cocktail_name}'.")
            return None
            
        final_abv = (total_alcohol_vol / total_vol) * 100.0
        
        return {
            "name": name,
            "volumeMl": round(total_vol, 1),
            "abvPercentage": round(final_abv, 1),
            "ingredients": ingredients
        }
        
    except Exception as e:
        print(f"[Error] Errore durante il recupero di '{cocktail_name}': {e}")
        return None

def main():
    print("[Info] Avvio dello scraping dei drink comuni...")
    results = []
    
    for name in POPULAR_COCKTAILS:
        print(f"[Info] Recupero ricetta per: {name}...")
        drink_info = fetch_cocktail_data(name)
        if drink_info:
            # Salviamo una versione semplificata per il database dei preset
            preset_entry = {
                "name": drink_info["name"],
                "volumeMl": drink_info["volumeMl"],
                "abvPercentage": drink_info["abvPercentage"]
            }
            results.append(preset_entry)
            print(f"   [OK] Trovato: {drink_info['name']} -> {drink_info['volumeMl']}ml, {drink_info['abvPercentage']}% ABV")
            
    # Salva il risultato in formato JSON
    output_file = "drinks_presets.json"
    with open(output_file, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)
        
    print(f"\n[Info] Completato! File '{output_file}' creato con {len(results)} drink comuni.")

if __name__ == "__main__":
    main()
