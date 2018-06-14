# Identdocstore proto
Identification documents storage service thrift protocol.



# Требования к оформлению Thrift IDL файлов

- __Namespace:__ 

	В каждом файле нужно __обязательно__ указывать `namespace` для __JAVA__:
		
		namespace java com.rbkmoney.identdocstore.<name>
			
	Где `<name>` - имя, уникальное для Thrift IDL файлa в Damsel.
	
	
# Java development

Собрать дамзель и инсталировать новый jar в локальный мавен репозиторий:

* make wc_compile
* make wc_java_install LOCAL_BUILD=true SETTINGS_XML=path_to_rbk_maven_settings

Чтобы ипользовать несколько версий дамзели в проекте используте classifier:v${commit.number}

```
<dependency>
    <groupId>com.rbkmoney</groupId>
    <artifactId>identdocstore-proto</artifactId>
    <version>1.5-27d975f</version>
    <classifier>v1</classifier>
</dependency>
```
