function cleanAreaName(areaName) {
    const DEFAULT_AREA_TYPES = [
        "COM", "DEP", "ZNIEFF1", "ZNIEFF2", "APB", "RNR", "RNN",
        "ZPS", "SIC", "ZICO", "PNR", "RBIOL", "RBIOS", "ZSC",
        "PSIC", "ENS", "PRIF", "INTERCOM"
    ];

    const found = DEFAULT_AREA_TYPES.some(code => areaName.includes(code));

    if (found && areaName.includes("-")) {
        return areaName.substring(areaName.indexOf("-")+ 1).trim(); // Découpe sur le premier tiret
    } else {
        return areaName;
    }
}

function highlightThreatened(doc, nomColonneCible = "Menace", 
                        texteRecherche = "true", couleurFond = "#ffcccc") {
    const body = doc.content[1].table.body;
  
    // Trouver l'index de la colonne "Menace" dans l'en-tête
    const header = body[0];
    let colonneIndex = header.findIndex(cell => cell.text.trim() === nomColonneCible);
  
    if (colonneIndex === -1) {
      console.warn(`Colonne "${nomColonneCible}" non trouvée dans l'en-tête PDF.`);
      return;
    }
  
    // Parcourir chaque ligne de données
    for (let i = 1; i < body.length; i++) {
      const row = body[i];
      const valeur = row[colonneIndex].text;
  
      // Vérifie si le texte correspond (true ou chaîne)
      if (valeur.includes(String(texteRecherche))) {
        row.forEach(cell => {
          cell.fillColor = couleurFond;
        });
      }
    }
  }
  

