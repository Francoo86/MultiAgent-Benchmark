import json
from collections import defaultdict
import os

print(os.getcwd())

def load_json_file(filename):
    """Carga un archivo JSON y maneja posibles errores."""
    try:
        with open(filename, 'r', encoding='utf-8') as file:
            return json.load(file)
    except FileNotFoundError:
        print(f"Error: No se encontró el archivo {filename}")
        return None
    except json.JSONDecodeError:
        print(f"Error: El archivo {filename} no es un JSON válido")
        return None
    except Exception as e:
        print(f"Error inesperado al cargar {filename}: {str(e)}")
        return None

def calculate_te(horarios_salas):
    """Calcula la métrica Time-slot Eligibility (TE)."""
    # Definir constantes
    DIAS = ['Lunes', 'Martes', 'Miercoles', 'Jueves', 'Viernes']
    TOTAL_PERIODOS = 9  # 9 bloques por día
    TOTAL_SLOTS = len(DIAS) * TOTAL_PERIODOS

    # Crear diccionario para almacenar eventos y sus períodos disponibles
    eventos = defaultdict(set)
    
    # Para cada sala, obtener los eventos y sus períodos ocupados
    for sala in horarios_salas:
        for asignatura in sala['Asignaturas']:
            evento_key = f"{asignatura['Nombre']}_{sala['Codigo']}"
            dia_name = asignatura['Dia'].capitalize()
            dia_idx = DIAS.index(dia_name)
            bloque = asignatura['Bloque']
            periodo = dia_idx * TOTAL_PERIODOS + bloque
            eventos[evento_key].add(periodo)

    # Si no hay eventos, retornar 0
    if not eventos:
        return 0

    # Calcular TE para cada evento
    te_values = []
    for evento, periodos_ocupados in eventos.items():
        # Los períodos disponibles son todos menos los ocupados
        periodos_disponibles = TOTAL_SLOTS - len(periodos_ocupados)
        te_individual = periodos_disponibles / TOTAL_SLOTS
        te_values.append(te_individual)

    # Calcular TE promedio
    te_promedio = sum(te_values) / len(eventos)
    
    return te_promedio

def main():
    # Cargar datos
    horarios_salas = load_json_file('agent_output/Horarios_salas.json')
    if horarios_salas is None:
        return

    # Calcular TE
    te = calculate_te(horarios_salas)
    
    # Imprimir resultados
    print("\nResultados del análisis Time-slot Eligibility (TE):")
    print("-" * 50)
    print(f"TE promedio: {te:.4f}")
    print(f"Porcentaje de disponibilidad: {te * 100:.2f}%")
    
    # Guardar resultados en JSON
    results = {
        'te_value': te,
        'te_percentage': te * 100
    }
    
    #with open('metricas_te.json', 'w', encoding='utf-8') as f:
    #    json.dump(results, f, ensure_ascii=False, indent=2)
    
    #print("\nMétricas guardadas en 'metricas_te.json'")
    
def main_with_platform(platform : str):
    platform = platform.upper()
    print(f"Iniciando análisis de Time-slot Eligibility para {platform}")
    for scenario in ['full', 'medium', 'small']:
        horarios_salas = load_json_file(f'{platform}_Output/{scenario}/Horarios_salas.json')
        
        if not horarios_salas:
            print(f"Error al cargar datos para {scenario}")
            continue
        
        te = calculate_te(horarios_salas)
        print(f"TE promedio para {scenario}: {te:.4f}")
        
        # Guardar resultados
        results = {
            'scenario': scenario,
            'te_value': te,
            'te_percentage': te * 100
        }
        
        print(f"Resultados para {scenario}: {results}")
        
        # Guardar resultados en JSON
        with open(f'{platform}_output/{scenario}/metricas_te.json', 'w', encoding='utf-8') as f:
            json.dump(results, f, ensure_ascii=False, indent=2)
        
        print(f"Resultados guardados en 'metricas_te.json' para {scenario}")
        

if __name__ == "__main__":
    main_with_platform('SPADE')
    main_with_platform('JADE')