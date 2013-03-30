package org.regeinc.lang.generator

import org.regeinc.lang.el.Contract
import org.regeinc.lang.el.Type
import org.regeinc.lang.el.Entity

class TypeJ {
	private new(){		
	}
	static TypeJ typeJ
	def static TypeJ instance(){
		if(typeJ==null)
			typeJ = new TypeJ()
		return typeJ
	}
	
	def compile(Type type){
		if(type instanceof Contract){
			compile(type as Contract)
		}else if(type instanceof Entity){
			compile(type as Entity)
		}
	}

	def compile(Contract contract)'''
	«IF contract.visibility!=null»«contract.visibility.toString» «ENDIF
	»interface «contract.name» «IF contract.EXTENDS»extends «contract.type.name»«ENDIF»{
		«IF !contract.allMethodDeclaration.nullOrEmpty»
			«FOR methodDeclaration:contract.allMethodDeclaration»
				«MethodJ::instance.compile(methodDeclaration)»;
			«ENDFOR»
		«ENDIF»
	}
	'''

	def compile(Entity entity)'''
	«IF entity.visibility!=null»«entity.visibility.toString» «ENDIF»«IF entity.FINAL»final «ELSEIF entity.ABSTRACT»abstract «ENDIF
	»class «entity.name» «IF entity.EXTENDS»extends «entity.type.name» «ENDIF»«IF entity.IMPLEMENTS»implements «FOR contract:entity.allContract SEPARATOR ', '»«contract.name»«ENDFOR»«ENDIF»{
		«IF !entity.allAssociation.nullOrEmpty»
			«FOR association: entity.allAssociation»

				«AssociationJ::instance.compile(association)»
			«ENDFOR»
		«ENDIF»
		«IF !entity.allState.nullOrEmpty»
			«FOR state:entity.allState»

			public boolean is«state.name.toFirstUpper»(){
				«IF state.constraint!=null»return «ConditionJ::instance.compile(state.constraint.condition)»;«ELSE»return true;«ENDIF»
			}
			«ENDFOR»
		«ENDIF»
		«IF !entity.allMethodDefinition.nullOrEmpty»
			«FOR methodDefinition:entity.allMethodDefinition»

				«MethodJ::instance.compile(methodDefinition)»
			«ENDFOR»
		«ENDIF»
	}
	'''
}