var resourceName = "ak4y-multichar";
if (window.GetParentResourceName) {
	resourceName = window.GetParentResourceName();
}
window.postNUI = async (name = "defaultName", data = {}) => {
	try {
		const response = await fetch(`https://${resourceName}/${name}`, {
			method: "POST",
			headers: {
				"Content-Type": "application/json",
			},
			body: JSON.stringify(data),
		});
		return !response.ok ? null : response.json();
	} catch (error) {
		console.error(error);
	}
};

const app = Vue.createApp({
	data() {
		return {
			general: {
				show: false,
				iskelet: true,
				reviveBtn: true,
				playerOnScreen: false,
				targetIsDead: false,
			},
			targetData: {
				Head: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
				Body: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
				RightArm: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
				LeftArm: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
				RightLeg: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
				LeftLeg: {
					screenX : 0,
					screenY : 0,
					health: 100,
					damageTaken: {},
				},
			},
			doctorItems: [],
			draggedItem: null,
			translate: {},
		};
	},
	methods: {
		camClick(state){
			axios.post(`https://${resourceName}/camClick`, {state: state}).then((response) => {
				// console.log(response.data);
			});
		},

		revivePlayer() {
			axios.post(`https://${resourceName}/revivePlayer`).then((response) => {
				if (response.data != "error") {
					var usedItemName = response.data.itemName;
					// decrease item amount
					this.doctorItems[this.doctorItems.findIndex(x => x.label === usedItemName)].amount -= 1;
					// if item amount is 0, remove from list
					if (this.doctorItems[this.doctorItems.findIndex(x => x.label === usedItemName)].amount == 0) {
						this.doctorItems.splice(this.doctorItems.findIndex(x => x.label === usedItemName), 1);
					}
				}
			});
		},

		getStyle(part, state) {
			var selectedPart = this.targetData[part];
			var bodyLeft = this.targetData["Body"].screenX;
			if (this.general.targetIsDead) {
				return {
					transform: `translate(- ${selectedPart.screenX}%, -${selectedPart.screenY}%)`,
					top: (part == "Body" ? selectedPart.screenY + "%" : selectedPart.screenY + 4 + "%"),
					left: (state == "right" ? selectedPart.screenX - 5 + "%" : selectedPart.screenX - 14.5 + "%"),
				};
			}else{
				return {
					transform: `translate(- ${selectedPart.screenX}%, -${selectedPart.screenY}%)`,
					top: (part == "Body" ? selectedPart.screenY + "%" : selectedPart.screenY + 19 + "%"),
					left: (state == "right" ? selectedPart.screenX - 3 + "%" : selectedPart.screenX - 13.5 + "%"),  
				};
			}
		},


		initializeDragAndDrop() {
			const self = this;
			this.doctorItems.forEach((item, index) => {
				$("#draggable" + index).draggable({
					helper: "clone", // Sürükleme sırasında bir kopya oluşturur
					start: function (event, ui) {
						self.draggedItem = item // Sürüklenen öğeyi klonla
						// console.log("Dragged", self.draggedItem.label);
						ui.helper.css("cursor", "move"); // Sürüklenen öğe için cursor değişikliği
						ui.helper.css('z-index', 1000000);
					},
				});
			});

			$('.locationName').each(function() {
				$(this).droppable({
					over: function(event, ui) {
						ui.helper.addClass('highlighted'); // Droppable alanına gelince opaklığı artır
					},
					out: function(event, ui) {
						ui.helper.removeClass('highlighted'); // Droppable alandan çıkınca opaklığı azalt
					},
					drop: function (event, ui) {
						// Drop işlemi gerçekleştiğinde
						// dropped Item id'si
						var healedPart = this.id
						var usedItem = self.draggedItem
						
						// healedPart (droppable-Body) to just (Body)
						healedPart = healedPart.replace("droppable-", "");

						if (self.targetData[healedPart].health < 100) {
							console.log("Healed Part: ", healedPart);
							axios.post(`https://${resourceName}/healBodyPart`, { healedPart: healedPart, usedItem: usedItem }).then((response) => {
								if (response.data == "ok") {
									// decrease item amount 
									self.doctorItems[self.doctorItems.findIndex(x => x.label === usedItem.label)].amount -= 1;

									// if item amount is 0, remove from list
									if (self.doctorItems[self.doctorItems.findIndex(x => x.label === usedItem.label)].amount == 0) {
										self.doctorItems.splice(self.doctorItems.findIndex(x => x.label === usedItem.label), 1);
									}
								}
							});
						}					
						ui.helper.removeClass('highlighted'); // Drop işlemi sonrası opaklığı normalleştir
					}
				});
			});
		},

		keyHandler(event) {
			if (event.which == 27) {
				if (this.general.show) {
					this.general.show = false;
					postNUI("closeMenu");
				}
			}
		},

		// Function to handle category change
	},
	computed: {
		getTranslate(){
			return this.translate;
		},


		getRemainingHealthOfParts() {
			return {
				Head: this.targetData.Head.health,
				Body: this.targetData.Body.health,
				RightArm: this.targetData.RightArm.health,
				LeftArm: this.targetData.LeftArm.health,
				RightLeg: this.targetData.RightLeg.health,
				LeftLeg: this.targetData.LeftLeg.health,
			};
		},

		// Adjusting opacity according to the health level of the parts; if health is 100, opacity will be 0, if health is 0, opacity will be 1 and intermediate values will be organized in this way.
		getOpacityOfParts() {
			return {
				Head: 1 - this.targetData.Head.health / 100,
				Body: 1 - this.targetData.Body.health / 100,
				RightArm: 1 - this.targetData.RightArm.health / 100,
				LeftArm: 1 - this.targetData.LeftArm.health / 100,
				RightLeg: 1 - this.targetData.RightLeg.health / 100,
				LeftLeg: 1 - this.targetData.LeftLeg.health / 100,
			};
		},

		getGeneralDamageTaken() {
			const parts = ["Head", "Body", "RightArm", "LeftArm", "RightLeg", "LeftLeg"];
			const generalDamage = new Map();

			parts.forEach((part) => {
				const damage = this.targetData[part].damageTaken;
				for (const [key, value] of Object.entries(damage)) {
					if (generalDamage.has(value)) {
						if (generalDamage.get(value) != "Bleeding") {
							generalDamage.set(value, generalDamage.get(value) + 1);
						}
					} else {
						generalDamage.set(value, 1);
					}
				}
			});

			const result = [];
			generalDamage.forEach((count, damageType) => {
				result.push({ type: damageType, count: count });
			});

			return result;
		},
	},
	watch: {},
	mounted() {
		this.initializeDragAndDrop();
		window.addEventListener("message", (event) => {
			if (event.data.action == "show") {
				this.general.show = true;
				this.translate = event.data.translate;
				var itemList = event.data.itemList;
				this.doctorItems = itemList;
				// clear all damageTaken data
				for (var key in this.targetData) {
					this.targetData[key].damageTaken = {};
				}
				this.general.targetIsDead = event.data.targetIsDead;
				setTimeout(() => {
					this.initializeDragAndDrop();
				}, 150);
				// console.log("itemList", JSON.stringify(this.doctorItems));
			} else if (event.data.action == "updateBodyPart") {
				// set target body part data
				var bodyParts = event.data.bodyPart;
				var groupTaken = event.data.groupTaken;
				var groupHealth = event.data.groupHealth;

				this.targetData[bodyParts].screenX = event.data.screenCoordX;
				this.targetData[bodyParts].screenY = event.data.screenCoordY;	
				this.general.playerOnScreen = event.data.onScreen;			


				// if var's not empty, set target data
				// control each body part's damageTaken and health seperate

				if (groupTaken != null) this.targetData[bodyParts].damageTaken = groupTaken;
				if (groupHealth != null) this.targetData[bodyParts].health = groupHealth;
			} else if (event.data.action == "hide") {
				this.general.show = false;
			}
			if (event.data.action == "hideRevive") {
				this.general.reviveBtn = false;
			} else if (event.data.action == "showRevive") {
				this.general.reviveBtn = true;
			}
		});
		window.addEventListener("keyup", this.keyHandler);
		// window.postNUI("getData");
	},
});

app.mount("#app");
