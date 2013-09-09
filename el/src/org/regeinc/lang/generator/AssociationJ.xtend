package org.regeinc.lang.generator

import org.regeinc.lang.el.Association
import org.regeinc.lang.el.Entity
import org.regeinc.lang.el.QualifiedReference

class AssociationJ {
	private new(){		
	} 
	static AssociationJ associationJ
	def static AssociationJ instance(){
		if(associationJ==null)
			associationJ = new AssociationJ()
		return associationJ
	}
	 
	def compile(Association association)'''
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»«TypeJ::instance.compile(association.qualifiedReference.reference.parameterizedType)» «association.qualifiedReference.reference.name»;
		«getter(association)»
		«setter(association)»
		«builder(association)»
	'''

	def getter(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»«TypeJ::instance.compile(association.qualifiedReference.reference.parameterizedType)
		» get«association.qualifiedReference.reference.name.toFirstUpper»(){
			return this.«association.qualifiedReference.reference.name»;
		}
	'''

	def setter(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF
		»void set«association.qualifiedReference.reference.name.toFirstUpper»(«
		TypeJ::instance.compile(association.qualifiedReference.reference.parameterizedType)» «association.qualifiedReference.reference.name»){
			«IF association.qualifiedReference.reference.NOTNULL»«compileNotNullPrefix(association.qualifiedReference)»«ENDIF»
			«IF association.qualifiedReference.typePrefix!=null»«
				new TypePrefixJ(association.qualifiedReference.reference.name).applyConstraint(association.qualifiedReference.typePrefix)»«ENDIF»
			«IF association.constraint!=null»«
				ConditionJ::instance.applyConstraint(association.constraint.condition, association.qualifiedReference.reference.name)»«ENDIF»
			this.«association.qualifiedReference.reference.name» = «association.qualifiedReference.reference.name»;
		}
	'''

	def builder(Association association)'''
		
		«IF association.visibility!=null»«association.visibility.toString» «ENDIF»«
		(association.eContainer as Entity).name» with«association.qualifiedReference.reference.name.toFirstUpper»(«
			TypeJ::instance.compile(association.qualifiedReference.reference.parameterizedType)» «association.qualifiedReference.reference.name»){
			«IF association.qualifiedReference.reference.NOTNULL»«compileNotNullPrefix(association.qualifiedReference)»«ENDIF»
			«IF association.qualifiedReference.typePrefix!=null»«»«ENDIF»
			«IF association.constraint!=null»«»«ENDIF»
			this.«association.qualifiedReference.reference.name» = «association.qualifiedReference.reference.name»;
			return this;
		}'''

	def compileNotNullPrefix(QualifiedReference qualifiedReference)'''		
		if(«qualifiedReference.reference.name» == null){
			throw new IllegalArgumentException("a null value could not be assigned to a notnull declared field «qualifiedReference.reference.name»");
		}
	'''	
}