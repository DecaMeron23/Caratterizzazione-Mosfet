from calcolo_parametri import vth

if __name__ == "__main__":

    vth_TCM = vth.TCM("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N4/Chip4NMOS/N4-100-30")
    vth_SDLM = vth.SDLM("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N4/Chip4NMOS/N4-100-30")
    vth_RM = vth.RM("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N4/Chip4NMOS/N4-100-30")
    vth_FIT = vth.FIT_LIN("/home/emilio/Documenti/github/Caratterizzazione-Mosfet/Misure statiche/N4/Chip4NMOS/N4-100-30")
    print(f"Risultati:\n\t-TCM:{vth_TCM}\n\t-SDLM:{vth_SDLM}\n\t-RM:{vth_RM}\n\t-FIT LIN:{vth_FIT}")
    input("Premere invio per terminare...")