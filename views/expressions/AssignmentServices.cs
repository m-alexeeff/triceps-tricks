// Покажет в панели загрузки СТО первые 10 услуг из заказ-наряда

(Vendor == null ? "" : Vendor.Name) + " "
	+ (VehicleModel == null ? "" : format("{0}",VehicleModel.Name) )
	+ "Приемщик: " + (Examiner == null ? "не указан" : Examiner.Name) + " "
	+ (Post == null ? "" : format("{0}",Post.Name))
	+ format("{0:HH:mm} - {1:HH:mm}", DateTimeIn, DateTimeOut) +
"

"
+ (this.Services[0] == null ? "" : this.Services[0].Service.Name) +
+ (this.Services[1] == null ? "" : ", "+ this.Services[1].Service.Name)
+ (this.Services[2] == null ? "" : ", "+ this.Services[2].Service.Name)
+ (this.Services[3] == null ? "" : ", "+ this.Services[3].Service.Name)
+ (this.Services[4] == null ? "" : ", "+ this.Services[4].Service.Name)
+ (this.Services[5] == null ? "" : ", "+ this.Services[5].Service.Name)
+ (this.Services[6] == null ? "" : ", "+ this.Services[6].Service.Name)
+ (this.Services[7] == null ? "" : ", "+ this.Services[7].Service.Name)
+ (this.Services[8] == null ? "" : ", "+ this.Services[8].Service.Name)
+ (this.Services[9] == null ? "" : ", "+ this.Services[9].Service.Name)