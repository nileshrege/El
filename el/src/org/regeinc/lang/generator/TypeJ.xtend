package org.regeinc.lang.generator

import org.regeinc.lang.el.Association
import org.regeinc.lang.el.Contract
import org.regeinc.lang.el.Entity
import org.regeinc.lang.el.Type
import java.util.List
import java.util.ArrayList

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
		«constructor(entity)»
		«equals(entity)»
	}
	'''
	
	def private constructor(Entity entity)'''
		«IF !getIdentities(entity).nullOrEmpty»
		
		public «entity.name»(«FOR a:getIdentities(entity) SEPARATOR ', ' »«a.qualifiedReference.reference.parameterizedType.type.name» «a.qualifiedReference.reference.name»«ENDFOR»){
			«FOR association:getIdentities(entity)»
				«IF association.constraint!=null»«ConditionJ::instance.applyConstraint(association.constraint.condition, association.qualifiedReference.reference.name)»«ENDIF»
				this.«association.qualifiedReference.reference.name» = «association.qualifiedReference.reference.name»;
			«ENDFOR»
		}«ENDIF»
	'''

	def List<Association> getIdentities(Entity entity){
		var allAssociation = new ArrayList()
		for(Association a: entity.allAssociation){
			if(a.IDENTITY)
				allAssociation.add(a)
		}
		return allAssociation;
	}

	def equals(Entity entity)'''
		
		public boolean equals(Object obj) {
			if(obj == null){
				return false;
			}
			if(obj == this){
				return true;
			}
			if(!(obj instanceof «entity.name»)){
				return false;
			}else{
				«entity.name» other = («entity.name»)obj;
				return «FOR a:getIdentities(entity) SEPARATOR ' && '»«
            		a.qualifiedReference.reference.name».equals(other.get«a.qualifiedReference.reference.name.toFirstUpper»())«ENDFOR»;
			}
		}
	'''
	
}